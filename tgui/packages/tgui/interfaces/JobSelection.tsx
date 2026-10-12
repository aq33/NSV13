// AQUILA - wybór profesji przy dołączaniu w trakcie rundy (aquila/code/modules/mob/dead/new_player/latejoin_menu.dm)
import {
  Box,
  Button,
  Icon,
  NoticeBox,
  Section,
  Stack,
} from 'tgui-core/components';

import { useBackend } from '../backend';
import { Window } from '../layouts';

type JobInfo = {
  title: string;
  hud: string;
  command: boolean;
};

type Department = {
  name: string;
  color: string;
  jobs: JobInfo[];
};

type JobStatus = {
  current: number;
  total: number;
  prioritized: boolean;
  unavailable: string | null;
};

type Data = {
  departments: Department[];
  jobs: Record<string, JobStatus>;
  round_duration: string;
  evacuation: string | null;
};

const slotsText = (status: JobStatus) =>
  status.total < 0
    ? `${status.current}/∞`
    : `${status.current}/${status.total}`;

const JobButton = (props: { job: JobInfo; status: JobStatus }) => {
  const { act } = useBackend<Data>();
  const { job, status } = props;
  const full = status.total >= 0 && status.current >= status.total;
  return (
    <Button
      fluid
      disabled={!!status.unavailable}
      color={status.prioritized ? 'good' : 'transparent'}
      tooltip={
        status.unavailable ||
        (status.prioritized
          ? 'Starszy Oficer oznaczył to stanowisko jako priorytetowe.'
          : undefined)
      }
      tooltipPosition="right"
      onClick={() => act('select_job', { job: job.title })}
    >
      <Stack align="center">
        <Stack.Item>
          <Box
            className={`job-icon16x16 job-icon-hud${job.hud}`}
            style={{ verticalAlign: 'middle' }}
          />
        </Stack.Item>
        <Stack.Item grow bold={job.command}>
          {job.title}
          {status.prioritized && <Icon name="star" ml={0.5} />}
        </Stack.Item>
        <Stack.Item color={full ? 'bad' : 'label'}>
          {slotsText(status)}
        </Stack.Item>
      </Stack>
    </Button>
  );
};

const DepartmentSection = (props: { department: Department }) => {
  const { data } = useBackend<Data>();
  const { department } = props;
  const jobs = department.jobs.filter((job) => data.jobs[job.title]);
  const open = jobs.filter((job) => !data.jobs[job.title].unavailable).length;
  return (
    <Box
      mb={1}
      style={{
        breakInside: 'avoid',
        borderLeft: `3px solid ${department.color}`,
      }}
    >
      <Section
        title={<Box color={department.color}>{department.name}</Box>}
        buttons={
          <Box color="label" mt={0.5}>
            otwarte: {open}
          </Box>
        }
      >
        {jobs.length ? (
          jobs.map((job) => (
            <JobButton
              key={job.title}
              job={job}
              status={data.jobs[job.title]}
            />
          ))
        ) : (
          <Box color="label" italic>
            Brak otwartych pozycji.
          </Box>
        )}
      </Section>
    </Box>
  );
};

export const JobSelection = () => {
  const { data } = useBackend<Data>();
  const { departments, round_duration, evacuation, jobs } = data;
  const anyPrioritized = Object.values(jobs).some((job) => job.prioritized);
  return (
    <Window title="Wybierz profesję" width={900} height={680}>
      <Window.Content scrollable>
        <NoticeBox info>
          <Icon name="clock" mr={1} />
          Czas rundy: {round_duration}
        </NoticeBox>
        {!!evacuation && <NoticeBox danger>{evacuation}</NoticeBox>}
        {anyPrioritized && (
          <NoticeBox success>
            Stanowiska oznaczone gwiazdką są priorytetowe. Rozważ dołączenie w
            jednej z tych ról.
          </NoticeBox>
        )}
        <Box style={{ columnWidth: '16em', columnGap: '0.5em' }}>
          {departments.map((department) => (
            <DepartmentSection key={department.name} department={department} />
          ))}
        </Box>
      </Window.Content>
    </Window>
  );
};
