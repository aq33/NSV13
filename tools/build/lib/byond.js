import { spawnSync } from 'child_process';
import fs from 'fs';
import path from 'path';
import Juke from '../juke/index.js';
import { regQuery } from './winreg.js';

/**
 * Cached path to DM compiler
 */
let dmPath;

/**
 * Reads the required BYOND version from dependencies.sh.
 * @returns {{ major: number, minor: number } | null}
 */
const getRequiredVersion = () => {
  try {
    const content = fs.readFileSync('dependencies.sh', 'utf-8');
    const major = content.match(/BYOND_MAJOR=(\d+)/);
    const minor = content.match(/BYOND_MINOR=(\d+)/);
    if (major && minor) {
      return { major: Number(major[1]), minor: Number(minor[1]) };
    }
  }
  catch (err) {}
  return null;
};

/**
 * Asks a DM compiler for its version. Running dm without arguments
 * only prints the version and usage, it does not compile anything.
 * @returns {{ major: number, minor: number } | null}
 */
const getDmVersion = (dmExe) => {
  try {
    const { stdout, stderr } = spawnSync(dmExe, [], {
      encoding: 'utf-8',
      timeout: 10000,
      windowsHide: true,
    });
    const match = `${stdout}${stderr}`.match(/version (\d+)\.(\d+)/);
    if (match) {
      return { major: Number(match[1]), minor: Number(match[2]) };
    }
  }
  catch (err) {}
  return null;
};

const isVersionOk = (version, required) => {
  if (!required) {
    return true;
  }
  if (!version) {
    return false;
  }
  // The code is written against one major version, so another major
  // (older or newer) is rejected. Newer minors of the same major are fine.
  return version.major === required.major
    && version.minor >= required.minor;
};

const getCacheDir = () => (
  process.env.TG_BOOTSTRAP_CACHE
  || path.resolve('tools/bootstrap/.cache')
);

/**
 * Downloads the required BYOND version into the bootstrap cache
 * (Windows only) and returns the path to its dm.exe.
 */
const downloadByond = async (required) => {
  const version = `${required.major}.${required.minor}`;
  const targetDir = path.join(getCacheDir(), `byond-${version}`);
  const dmExe = path.join(targetDir, 'byond', 'bin', 'dm.exe');
  if (isFile(dmExe)) {
    return dmExe;
  }
  const url = `https://www.byond.com/download/build/${required.major}/${version}_byond.zip`;
  const zipFile = path.join(getCacheDir(), `byond-${version}.zip`);
  Juke.logger.info(`Downloading BYOND ${version} from ${url}`);
  fs.mkdirSync(targetDir, { recursive: true });
  const response = await fetch(url);
  if (!response.ok) {
    throw new Error(`BYOND download failed: HTTP ${response.status}`);
  }
  fs.writeFileSync(zipFile, Buffer.from(await response.arrayBuffer()));
  // tar ships with Windows 10 and newer and can unpack zip files.
  // Use the system one: a GNU tar from Git Bash on PATH can't handle drive letter paths.
  const tarExe = path.join(process.env.SystemRoot || 'C:\\Windows', 'System32', 'tar.exe');
  const result = spawnSync(isFile(tarExe) ? tarExe : 'tar', ['-xf', zipFile, '-C', targetDir], {
    stdio: 'inherit',
    windowsHide: true,
  });
  fs.rmSync(zipFile, { force: true });
  if (result.status !== 0 || !isFile(dmExe)) {
    throw new Error(`Could not unpack BYOND ${version} into ${targetDir}`);
  }
  Juke.logger.info(`BYOND ${version} installed to ${targetDir}`);
  return dmExe;
};

const isFile = path => {
  try {
    return fs.statSync(path).isFile();
  }
  catch (err) {
    return false;
  }
};

const resolveDmExe = async (candidate) => {
  // Resolve a registry key
  if (Array.isArray(candidate)) {
    const [type, ...args] = candidate;
    candidate = await regQuery(...args);
  }
  if (!candidate) {
    return null;
  }
  for (const file of [candidate, candidate + '/dm.exe', candidate + '/bin/dm.exe']) {
    if (isFile(file)) {
      return file;
    }
  }
  return null;
};

const getDmPath = async () => {
  if (dmPath) {
    return dmPath;
  }
  dmPath = await (async () => {
    const required = getRequiredVersion();
    // An explicitly configured compiler always wins
    const envPaths = (process.env.DM_EXE && process.env.DM_EXE.split(',')) || [];
    for (const candidate of envPaths) {
      const dmExe = await resolveDmExe(candidate);
      if (dmExe) {
        return dmExe;
      }
    }
    // Search in array of paths, skipping wrong BYOND versions
    const paths = [
      required && path.join(getCacheDir(), `byond-${required.major}.${required.minor}`, 'byond', 'bin', 'dm.exe'),
      'C:\\Program Files\\BYOND\\bin\\dm.exe',
      'C:\\Program Files (x86)\\BYOND\\bin\\dm.exe',
      ['reg', 'HKLM\\Software\\Dantom\\BYOND', 'installpath'],
      ['reg', 'HKLM\\SOFTWARE\\WOW6432Node\\Dantom\\BYOND', 'installpath'],
    ];
    for (const candidate of paths) {
      const dmExe = await resolveDmExe(candidate);
      if (!dmExe) {
        continue;
      }
      const version = getDmVersion(dmExe);
      if (isVersionOk(version, required)) {
        return dmExe;
      }
      Juke.logger.warn(`Skipping ${dmExe}: BYOND ${version ? `${version.major}.${version.minor}` : '(unknown version)'}, need ${required.major}.${required.minor}`);
    }
    // Nothing suitable installed - fetch the right version on Windows
    if (process.platform === 'win32' && required) {
      return downloadByond(required);
    }
    // Default paths
    return (
      process.platform === 'win32' && 'dm.exe'
      || 'DreamMaker'
    );
  })();
  return dmPath;
};

/**
 * @param {string} dmeFile
 * @param {{
 *   defines?: string[];
 *   warningsAsErrors?: boolean;
 * }} options
 */
export const DreamMaker = async (dmeFile, options = {}) => {
  const dmPath = await getDmPath();
  // Get project basename
  const dmeBaseName = dmeFile.replace(/\.dme$/, '');
  // Make sure output files are writable
  const testOutputFile = (name) => {
    try {
      fs.closeSync(fs.openSync(name, 'r+'));
    }
    catch (err) {
      if (err && err.code === 'ENOENT') {
        return;
      }
      if (err && err.code === 'EBUSY') {
        Juke.logger.error(`File '${name}' is locked by the DreamDaemon process.`);
        Juke.logger.error(`Stop the currently running server and try again.`);
        throw new Juke.ExitCode(1);
      }
      throw err;
    }
  };
  testOutputFile(`${dmeBaseName}.dmb`);
  testOutputFile(`${dmeBaseName}.rsc`);
  const runWithWarningChecks = async (dmeFile, args) => {
    const execReturn = await Juke.exec(dmeFile, args);
    if (options.warningsAsErrors && execReturn.combined.match(/\d+:warning: /)) {
      Juke.logger.error(`Compile warnings treated as errors`);
      throw new Juke.ExitCode(2);
    }
    return execReturn;
  }
  // Compile
  const { defines } = options;
  if (defines && defines.length > 0) {
    Juke.logger.info('Using defines:', defines.join(', '));
    try {
      const injectedContent = defines
        .map(x => `#define ${x}\n`)
        .join('');
      fs.writeFileSync(`${dmeBaseName}.m.dme`, injectedContent);
      const dmeContent = fs.readFileSync(`${dmeBaseName}.dme`);
      fs.appendFileSync(`${dmeBaseName}.m.dme`, dmeContent);
      await Juke.exec(dmPath, [`${dmeBaseName}.m.dme`]);
      fs.writeFileSync(`${dmeBaseName}.dmb`, fs.readFileSync(`${dmeBaseName}.m.dmb`));
      fs.writeFileSync(`${dmeBaseName}.rsc`, fs.readFileSync(`${dmeBaseName}.m.rsc`));
    }
    finally {
      Juke.rm(`${dmeBaseName}.m.*`);
    }
  }
  else {
    await runWithWarningChecks(dmPath, [dmeFile]);
  }
};

export const DreamDaemon = async (dmbFile, ...args) => {
  const dmPath = await getDmPath();
  const baseDir = path.dirname(dmPath);
  const ddExeName = process.platform === 'win32' ? 'dreamdaemon.exe' : 'DreamDaemon';
  const ddExePath = baseDir === '.' ? ddExeName : path.join(baseDir, ddExeName);
  return Juke.exec(ddExePath, [dmbFile, ...args]);
};
