import { createSearch } from 'common/string';
import { Box, Icon, Input, Section } from 'tgui-core/components';

import { useBackend, useLocalState } from '../backend';
import { NtosWindow } from '../layouts';

type Data = {
  mode: any;
  records: any;
};

export const NtosRecords = (props) => {
  const { act, data } = useBackend<Data>();
  const [searchTerm, setSearchTerm] = useLocalState('search', '');
  const { mode, records } = data;

  const isMatchingSearchTerms = createSearch(
    searchTerm,
    (text: string) => text,
  );

  return (
    <NtosWindow width={600} height={800}>
      <NtosWindow.Content scrollable>
        <Section textAlign="center">
          NANOTRASEN PERSONNEL RECORDS (CLASSIFIED)
        </Section>
        <Section>
          <Input
            placeholder={'Filter results...'}
            value={searchTerm}
            fluid
            textAlign="center"
            onInput={(e, value) => setSearchTerm(value)}
          />
        </Section>
        {mode === 'security' &&
          records.map((record) => (
            <Section
              key={record.id}
              style={
                !(
                  searchTerm === '' ||
                  isMatchingSearchTerms(
                    record.name +
                      ' ' +
                      record.rank +
                      ' ' +
                      record.species +
                      ' ' +
                      record.sex +
                      ' ' +
                      record.age +
                      ' ' +
                      record.fingerprint,
                  )
                )
                  ? { display: 'none' }
                  : undefined
              }
            >
              <Box bold>
                <Icon name="user" mr={1} />
                {record.name}
              </Box>
              <br />
              Rank: {record.rank}
              <br />
              Species: {record.species}
              <br />
              Sex: {record.sex}
              <br />
              Age: {record.age}
              <br />
              Fingerprint: {record.fingerprint}
              <br />
              <br />
              Criminal Status: {record.wanted || 'DELETED'}
            </Section>
          ))}
        {mode === 'medical' &&
          records.map((record) => (
            <Section
              key={record.id}
              style={
                !(
                  searchTerm === '' ||
                  isMatchingSearchTerms(
                    record.name +
                      ' ' +
                      record.rank +
                      ' ' +
                      record.species +
                      ' ' +
                      record.sex +
                      ' ' +
                      record.age +
                      ' ' +
                      record.fingerprint +
                      ' ' +
                      record.bloodtype +
                      ' ' +
                      record.m_stat +
                      ' ' +
                      record.p_stat,
                  )
                )
                  ? { display: 'none' }
                  : undefined
              }
            >
              <Box bold>
                <Icon name="user" mr={1} />
                {record.name}
              </Box>
              <br />
              Rank: {record.rank}
              <br />
              Species: {record.species}
              <br />
              Sex: {record.sex}
              <br />
              Age: {record.age}
              <br />
              DNA: {record.b_dna}
              <br />
              <br />
              Bloodtype: {record.bloodtype}
              <br />
              Minor Disabilities: {record.mi_dis}
              <br />
              Major Disabilities: {record.ma_dis}
              <br />
              Notes: {record.notes}
              <br />
              Notes Cont.d: {record.cnotes}
            </Section>
          ))}
      </NtosWindow.Content>
    </NtosWindow>
  );
};
