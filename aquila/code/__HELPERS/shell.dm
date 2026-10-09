// AQUILA EDIT - world.shelleo() na Windowsie bez okna konsoli.
// shell("cmd /c ...") z DreamDaemona otwiera widoczne okno terminala na hoście (np. przy każdym
// zapytaniu do yt-dlp z jukeboxa). wscript.exe jest aplikacją okienkową, więc sam nie tworzy konsoli,
// a WScript.Shell.Run(..., 0, true) odpala cmd z ukrytym oknem i czeka na kod wyjścia.

#define SHELL_HIDDEN_LAUNCHER "data/shelleo_hidden.js"

/// Uruchamia wiersz poleceń cmd (z przekierowaniami) bez okna. Zwraca kod wyjścia albo null, gdy się nie udało.
/proc/aquila_shell_hidden(command_line, cmdline_file, out_file)
	var/static/launcher_ready = FALSE
	if(!launcher_ready)
		rustg_file_write({"var fso = new ActiveXObject("Scripting.FileSystemObject");
var f = fso.OpenTextFile(WScript.Arguments(0), 1);
var cmd = f.ReadAll();
f.Close();
WScript.Quit(new ActiveXObject("WScript.Shell").Run("cmd /c \\"" + cmd + "\\"", 0, true));
"}, SHELL_HIDDEN_LAUNCHER)
		launcher_ready = TRUE
	// polecenie idzie przez plik, żeby nie walczyć z cytowaniem argumentów wscript
	rustg_file_write(command_line, cmdline_file)
	var/errorcode = shell("wscript //B //nologo [replacetext(SHELL_HIDDEN_LAUNCHER, "/", "\\")] [replacetext(cmdline_file, "/", "\\")]")
	fdel(cmdline_file)
	// cmd zawsze tworzy plik wyjścia przy przekierowaniu - brak pliku znaczy, że wscript nie zadziałał
	if(!fexists(out_file))
		return null
	return errorcode

#undef SHELL_HIDDEN_LAUNCHER
