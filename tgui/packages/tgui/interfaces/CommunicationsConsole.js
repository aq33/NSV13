import { sortBy } from "common/collections";
import { capitalize } from "common/string";
import { useBackend, useLocalState } from "../backend";
import { Blink, Box, Button, Dimmer, Flex, Icon, Input, LabeledList, Modal, NoticeBox, Section, Stack, Tabs, TextArea, Tooltip } from "../components";
import { Window } from "../layouts";
import { sanitizeText } from "../sanitize";

const STATE_BUYING_SHUTTLE = "buying_shuttle";
const STATE_CHANGING_STATUS = "changing_status";
const STATE_MESSAGES = "messages";
const STATE_OBJECTIVES = "objectives"; // NSV13 - objectives

// Used for whether or not you need to swipe to confirm an alert level change
const SWIPE_NEEDED = "SWIPE_NEEDED";

const ILLEGAL_SHUTTLE_NOTICE
  = "Uwaga: zabezpieczenia wyłączone. Ten prom nie ma certyfikatu. Zamawiasz na własne ryzyko.";

// Nazwy poziomów alarmu do wyświetlania (klucze to wartości z DM, nie zmieniać)
const ALERT_LEVEL_NAMES = {
  "condition 3": "Stan 3",
  "condition 2": "Stan 2",
  "general quarters": "Alarm bojowy",
  "condition zebra": "Stan Zebra",
};
const alertLevelName = level => ALERT_LEVEL_NAMES[level] || capitalize(level);
const sortShuttles = sortBy(
  shuttle => !shuttle.illegal,
  shuttle => shuttle.creditCost
);

const AlertButton = (props, context) => {
  const { act, data } = useBackend(context);
  const { alertLevelTick, canSetAlertLevel } = data;
  const { alertLevel, setShowAlertLevelConfirm } = props;

  const thisIsCurrent = data.alertLevel === alertLevel;

  return (
    <Button
      icon="exclamation-triangle"
      color={thisIsCurrent && "good"}
      content={alertLevelName(alertLevel)}
      onClick={() => {
        if (thisIsCurrent) {
          return;
        }

        if (canSetAlertLevel === SWIPE_NEEDED) {
          setShowAlertLevelConfirm([alertLevel, alertLevelTick]);
        } else {
          act("changeSecurityLevel", {
            newSecurityLevel: alertLevel,
          });
        }
      }}
    />
  );
};

const MessageModal = (props, context) => {
  const { data } = useBackend(context);
  const { maxMessageLength } = data;

  const [input, setInput] = useLocalState(context, props.label, "");

  const longEnough = props.minLength === undefined
    || input.length >= props.minLength;

  return (
    <Modal>
      <Stack vertical position="relative">
        <Stack.Item fontSize="16px" maxWidth="90vw">
          {props.label}:
        </Stack.Item>

        <Stack.Item>
          <TextArea
            fluid
            height="20vh"
            backgroundColor="black"
            textColor="white"
            onInput={(_, value) => {
              setInput(value.substring(0, maxMessageLength));
            }}
            value={input}
          />
        </Stack.Item>

        <Stack.Item>
          <Button
            icon={props.icon}
            content={props.buttonText}
            color="good"
            disabled={!longEnough}
            tooltip={!longEnough ? "Potrzebujesz dłuższego uzasadnienia." : ""}
            tooltipPosition="right"
            onClick={() => {
              if (longEnough) {
                setInput("");
                props.onSubmit(input);
              }
            }}
          />

          <Button
            icon="times"
            content="Anuluj"
            color="bad"
            onClick={props.onBack}
          />
        </Stack.Item>

        {!!props.notice && (
          <Stack.Item maxWidth="90vw">{props.notice}</Stack.Item>
        )}
      </Stack>
    </Modal>
  );
};

const NoConnectionModal = () => {
  return (
    <Dimmer>
      <Flex direction="column" textAlign="center" width="300px">
        <Flex.Item>
          <Icon
            color="red"
            name="wifi"
            size={10}
          />

          <Blink>
            <div
              style={{
                background: "#db2828",
                bottom: "60%",
                left: "25%",
                height: "10px",
                position: "relative",
                transform: "rotate(45deg)",
                width: "150px",
              }}
            />
          </Blink>
        </Flex.Item>

        <Flex.Item fontSize="16px">
          Nie można nawiązać połączenia ze statkiem.
        </Flex.Item>
      </Flex>
    </Dimmer>
  );
};

const PageBuyingShuttle = (props, context) => {
  const { act, data } = useBackend(context);
  const {
    canBuyShuttles,
  } = data;

  return (
    <>
      {canBuyShuttles !== 1 && (
        <Stack.Item>
          <NoticeBox danger>
            {canBuyShuttles}
          </NoticeBox>
        </Stack.Item>
      )}

      <Stack vertical fill>
        <Stack.Item>
          <Section>
            Budżet: <b>{data.budget.toLocaleString()}</b> kredytów
          </Section>
        </Stack.Item>

        <Stack.Item grow>
          <Section fill scrollable>
            <Stack vertical>
              {sortShuttles(data.shuttles).map(shuttle => (
                <Stack.Item key={shuttle.ref}>
                  <Section
                    title={(
                      <span
                        style={{
                          display: "inline-block",
                          width: "70%",
                        }}>
                        {shuttle.name}
                      </span>
                    )}
                    buttons={(
                      <Button
                        content={
                          `${shuttle.creditCost.toLocaleString()} kredytów`
                        }
                        color={shuttle.illegal ? "red" : "default"}
                        disabled={
                          !canBuyShuttles || data.budget < shuttle.creditCost
                        }
                        onClick={() => act("purchaseShuttle", {
                          shuttle: shuttle.ref,
                        })}
                        tooltip={
                          data.budget < shuttle.creditCost ? (`Brakuje ci ${
                            shuttle.creditCost - data.budget
                          } kredytów.`
                          ) : (shuttle.illegal
                            ? ILLEGAL_SHUTTLE_NOTICE
                            : undefined)
                        }
                        tooltipPosition="left"
                      />
                    )}>
                    <Box textAlign="justify">{shuttle.description}</Box>
                    {
                      shuttle.prerequisites
                        ? <b>Wymagania: {shuttle.prerequisites}</b>
                        : null
                    }
                  </Section>
                </Stack.Item>
              ))}
            </Stack>
          </Section>
        </Stack.Item>
      </Stack>
    </>
  );
};

const PageChangingStatus = (props, context) => {
  const { act, data } = useBackend(context);
  const { maxStatusLineLength } = data;

  const [lineOne, setLineOne] = useLocalState(context, "lineOne", data.lineOne);
  const [lineTwo, setLineTwo] = useLocalState(context, "lineTwo", data.lineTwo);

  return (
    <Box>
      <Section>
        <Flex direction="column">
          <Flex.Item>
            <Button
              icon="times"
              content="Wyczyść alarm"
              color="bad"
              onClick={() => act("setStatusPicture", { picture: "blank" })}
            />
          </Flex.Item>

          <Flex.Item mt={1}>
            <Button
              icon="check-square-o"
              content="Domyślny"
              onClick={() => act("setStatusPicture", { picture: "default" })}
            />

            <Button
              icon="bell-o"
              content="Alarm bojowy"
              onClick={() => act("setStatusPicture", { picture: "redalert" })}
            />

            <Button
              icon="exclamation-triangle"
              content="Blokada"
              onClick={() => act("setStatusPicture", { picture: "lockdown" })}
            />

            <Button
              icon="exclamation-circle"
              content="Zagrożenie biologiczne"
              onClick={() => act("setStatusPicture", { picture: "biohazard" })}
            />

            <Button
              icon="space-shuttle"
              content="Przylot promu"
              onClick={() => act("setStatusPicture", { picture: "shuttle" })}
            />
          </Flex.Item>
        </Flex>
      </Section>

      <Section title="Wiadomość">
        <Flex direction="column">
          <Flex.Item mb={1}>
            <Input
              maxLength={maxStatusLineLength}
              value={lineOne}
              width="200px"
              onChange={(_, value) => setLineOne(value)}
            />
          </Flex.Item>

          <Flex.Item mb={1}>
            <Input
              maxLength={maxStatusLineLength}
              value={lineTwo}
              width="200px"
              onChange={(_, value) => setLineTwo(value)}
            />
          </Flex.Item>

          <Flex.Item>
            <Button
              icon="comment-o"
              content="Wyświetl"
              onClick={() => act("setStatusMessage", {
                lineOne,
                lineTwo,
              })}
            />
          </Flex.Item>
        </Flex>
      </Section>
    </Box>
  );
};

const PageMain = (props, context) => {
  const { act, data } = useBackend(context);
  const {
    alertLevel,
    alertLevelTick,
    callShuttleReasonMinLength,
    canBuyShuttles,
    canMakeAnnouncement,
    canMessageAssociates,
    canRecallShuttles,
    canRequestNuke,
    canRequestERT,
    canSendToSectors,
    canSetAlertLevel,
    canToggleEmergencyAccess,
    emagged,
    emergencyAccess,
    importantActionReady,
    reinforcementActionReady,
    crewWakeActionReady,
    shuttleCalled,
    shuttleCalledPreviously,
    shuttleCanEvacOrFailReason,
    shuttleLastCalled,
    shuttleRecallable,
    page,
  } = data;

  const [callingShuttle, setCallingShuttle] = useLocalState(
    context, "calling_shuttle", false);
  const [messagingAssociates, setMessagingAssociates] = useLocalState(
    context, "messaging_associates", false);
  const [messagingSector, setMessagingSector] = useLocalState(
    context, "messaing_sector", null);
  const [requestingNukeCodes, setRequestingNukeCodes] = useLocalState(
    context, "requesting_nuke_codes", false);
  const [requestingResponseTeam, setRequestingResponseTeam] = useLocalState(
    context, "requesting_ert", false);
  const [requestingCrewWake, setRequestingCrewWake] = useLocalState(
    context, "requesting_crew_wake", false);



  const [
    [showAlertLevelConfirm, confirmingAlertLevelTick],
    setShowAlertLevelConfirm,
  ] = useLocalState(context, "showConfirmPrompt", [null, null]);

  return (
    <Box>
      <Section title="Prom ewakuacyjny">
        {
          shuttleCalled
            ? (
              <Button.Confirm
                icon="space-shuttle"
                content="Odwołaj prom ewakuacyjny"
                color="bad"
                disabled={!canRecallShuttles || !shuttleRecallable}
                tooltip={(
                  canRecallShuttles ? (
                    !shuttleRecallable && "Na odwołanie promu ewakuacyjnego jest już za późno."
                  ) : (
                    "Nie masz uprawnień do odwołania promu ewakuacyjnego."
                  )
                )}
                tooltipPosition="bottom-end"
                onClick={() => act("recallShuttle")}
              />
            ) : (
              <Button
                icon="space-shuttle"
                content="Wezwij prom ewakuacyjny"
                disabled={shuttleCanEvacOrFailReason !== 1}
                tooltip={
                  shuttleCanEvacOrFailReason !== 1
                    ? shuttleCanEvacOrFailReason
                    : undefined
                }
                tooltipPosition="bottom-end"
                onClick={() => setCallingShuttle(true)}
              />
            )
        }

        {!!shuttleCalledPreviously && (
          shuttleLastCalled && (
            <Box>
              Ostatnie wezwanie/odwołanie promu namierzono do:
              {" "}<b>{shuttleLastCalled}</b>
            </Box>
          ) || (
            <Box>Nie udało się namierzyć ostatniego sygnału wezwania/odwołania promu.</Box>
          )
        )}
      </Section>

      {!!canSetAlertLevel && (
        <Section title="Poziom alarmu">
          <Flex justify="space-between">
            <Flex.Item>
              <Box>
                Obecnie: <b>{alertLevelName(alertLevel)}</b>
              </Box>
            </Flex.Item>

            <Flex.Item>
              <AlertButton
                alertLevel="condition 3"
                showAlertLevelConfirm={showAlertLevelConfirm}
                setShowAlertLevelConfirm={setShowAlertLevelConfirm}
              />

              <AlertButton
                alertLevel="condition 2"
                showAlertLevelConfirm={showAlertLevelConfirm}
                setShowAlertLevelConfirm={setShowAlertLevelConfirm}
              />

              <AlertButton
                alertLevel="general quarters"
                showAlertLevelConfirm={showAlertLevelConfirm}
                setShowAlertLevelConfirm={setShowAlertLevelConfirm}
              />

              <AlertButton
                alertLevel="condition zebra"
                showAlertLevelConfirm={showAlertLevelConfirm}
                setShowAlertLevelConfirm={setShowAlertLevelConfirm}
              />
            </Flex.Item>
          </Flex>
        </Section>
      )}

      <Section title="Funkcje">
        <Flex
          direction="column">
          {!!canMakeAnnouncement && (
            <Flex.Item mt={0.3}>
              <Button fluid
                icon="bullhorn"
                content="Nadaj ogłoszenie priorytetowe"
                onClick={() => act("makePriorityAnnouncement")}
              />
            </Flex.Item>
          )}

          {!!canToggleEmergencyAccess && (
            <Flex.Item mt={0.3}>
              <Button.Confirm fluid
                icon="id-card-o"
                content={`${emergencyAccess ? "Wyłącz" : "Włącz"} awaryjny dostęp do technicznych`}
                color={emergencyAccess ? "bad" : undefined}
                onClick={() => act("toggleEmergencyAccess")}
              />
            </Flex.Item>
          )}

          {!!canMessageAssociates && (
            <Flex.Item mt={0.3}>
              <Button fluid
                icon="comment-o"
                content={`Wyślij wiadomość do ${emagged ? "[NIEZNANE]" : "CentComu"}`}
                disabled={!importantActionReady}
                onClick={() => setMessagingAssociates(true)}
              />
            </Flex.Item>
          )}

          {!!canRequestNuke && (
            <Flex.Item mt={0.3}>
              <Button fluid
                icon="radiation"
                content="Poproś o kody uwierzytelniania ładunku jądrowego"
                disabled={!importantActionReady}
                onClick={() => setRequestingNukeCodes(true)}
              />
            </Flex.Item>
          )}

          {!!canRequestERT && (
            <Flex.Item mt={0.3}>
              <Button fluid
                icon="dumpster-fire"
                content="Wezwij zespół reagowania kryzysowego"
                disabled={!reinforcementActionReady}
                onClick={() => setRequestingResponseTeam(true)}
              />
            </Flex.Item>
          )}

          {!!canRequestERT && (
            <Flex.Item mt={0.3}>
              <Button fluid
                icon="snowflake"
                content="Wybudź załogę z kriostazy"
                disabled={!crewWakeActionReady}
                onClick={() => setRequestingCrewWake(true)}
              />
            </Flex.Item>
          )}

          {!!emagged && (
            <Flex.Item mt={0.3}>
              <Button fluid
                icon="undo"
                content="Przywróć zapasowe dane routingu"
                onClick={() => act("restoreBackupRoutingData")}
              />
            </Flex.Item>
          )}

          {!canMakeAnnouncement
            && !canToggleEmergencyAccess
            && !canMessageAssociates
            && !canRequestNuke
            && !canRequestERT
            && !emagged
            && (
              <Flex.Item>
                Brak dostępnych funkcji
              </Flex.Item>
            )}
        </Flex>
      </Section>

      {!!canMessageAssociates && messagingAssociates && <MessageModal
        label={`Wiadomość do przesłania ${emagged ? "pod [NIEPRAWIDŁOWE WSPÓŁRZĘDNE ROUTINGU]" : "do CentComu"} przez splątanie kwantowe`}
        notice="Pamiętaj, że ten proces jest bardzo kosztowny, a nadużycia skończą się... zwolnieniem. Przesłanie nie gwarantuje odpowiedzi. Szefowie działów mogą z tego korzystać tylko w sytuacji awaryjnej."
        icon="bullhorn"
        buttonText="Wyślij"
        onBack={() => setMessagingAssociates(false)}
        onSubmit={message => {
          setMessagingAssociates(false);
          act("messageAssociates", {
            message,
          });
        }}
      />}

      {!!canRequestNuke && requestingNukeCodes && <MessageModal
        label="Powód prośby o kody autodestrukcji jądrowej"
        notice="Nadużycia systemu próśb o kody jądrowe nie będą tolerowane w żadnych okolicznościach. Przesłanie nie gwarantuje odpowiedzi."
        icon="bomb"
        buttonText="Poproś o kody"
        onBack={() => setRequestingNukeCodes(false)}
        onSubmit={reason => {
          setRequestingNukeCodes(false);
          act("requestNukeCodes", {
            reason,
          });
        }}
      />}

      {!!canRequestERT && requestingResponseTeam && <MessageModal
        label="Powód wezwania zespołu reagowania kryzysowego"
        notice="Nadużycia systemu wzywania zespołu reagowania nie będą tolerowane w żadnych okolicznościach. Przesłanie nie gwarantuje odpowiedzi."
        icon="bomb"
        buttonText="Wezwij ERT"
        onBack={() => setRequestingResponseTeam(false)}
        onSubmit={reason => {
          setRequestingResponseTeam(false);
          act("requestERT", {
            reason,
          });
        }}
      />}

      {!!canRequestERT && requestingCrewWake && <MessageModal
        label="Powód wybudzenia dodatkowej załogi z kriostazy"
        notice="Wybudzeni zostaną ochotnicy jako Majtkowie, przy komorach snu. Prośba nie gwarantuje odpowiedzi."
        icon="snowflake"
        buttonText="Wybudź załogę"
        onBack={() => setRequestingCrewWake(false)}
        onSubmit={reason => {
          setRequestingCrewWake(false);
          act("requestCrewWake", {
            reason,
          });
        }}
      />}

      {!!callingShuttle && <MessageModal
        label="Rodzaj zagrożenia"
        icon="space-shuttle"
        buttonText="Wezwij prom"
        minLength={callShuttleReasonMinLength}
        onBack={() => setCallingShuttle(false)}
        onSubmit={reason => {
          setCallingShuttle(false);
          act("callShuttle", {
            reason,
          });
        }}
      />}

      {
        !!canSetAlertLevel
        && showAlertLevelConfirm
        && confirmingAlertLevelTick === alertLevelTick
        && (
          <Modal>
            <Flex
              direction="column"
              textAlign="center"
              width="300px">
              <Flex.Item fontSize="16px" mb={2}>
                Przeciągnij ID, by potwierdzić zmianę
              </Flex.Item>

              <Flex.Item mr={2} mb={1}>
                <Button
                  icon="id-card-o"
                  content="Przeciągnij ID"
                  color="good"
                  fontSize="16px"
                  onClick={() => act("changeSecurityLevel", {
                    newSecurityLevel: showAlertLevelConfirm,
                  })}
                />

                <Button
                  icon="times"
                  content="Anuluj"
                  color="bad"
                  fontSize="16px"
                  onClick={() => setShowAlertLevelConfirm(false)}
                />
              </Flex.Item>
            </Flex>
          </Modal>
        )
      }

      {
        !!canSendToSectors
        && (
          <Section title="Sektory sojusznicze">
            <Button
              content="Wyślij wiadomość do sojuszniczych stacji"
              disabled={!importantActionReady}
              onClick={() => setMessagingSector(true)}
            />
          </Section>
        )
      }

      {
        !!canSendToSectors
        && messagingSector
        && <MessageModal
          label="Wiadomość do sojuszniczej stacji"
          notice="Pamiętaj, że ten proces jest bardzo kosztowny, a nadużycia skończą się... zwolnieniem."
          icon="bullhorn"
          buttonText="Wyślij"
          onBack={() => setMessagingSector(null)}
          onSubmit={message => {
            act("sendToOtherSector", {
              message,
            });

            setMessagingSector(null);
          }}
        />
      }
    </Box>
  );
};

const PageMessages = (props, context) => {
  const { act, data } = useBackend(context);
  const messages = data.messages || [];

  return (
    <Section fill scrollable title="Wiadomości">
      {
        messages.map((message, messageIndex) => {
          let answers = null;

          if (Object.keys(message.possibleAnswers).length > 0) {
            answers = (
              <Box mt={1}>
                {Object.entries(message.possibleAnswers).map((answer) => (
                  <Button
                    content={answer[1]}
                    color={message.answered === answer[0] ? "good" : undefined}
                    key={answer[0]}
                    onClick={message.answered ? undefined : () => act("answerMessage", {
                      message: messageIndex + 1,
                      answer: answer[0],
                    })}
                  />
                ))}
              </Box>
            );
          }

          const textHtml = {
            __html: sanitizeText(message.content),
          };

          return (
            <Section
              title={message.title}
              key={messageIndex}
              buttons={(
                <Button.Confirm
                  icon="trash"
                  content="Usuń"
                  color="red"
                  onClick={() => act("deleteMessage", {
                    message: messageIndex + 1,
                  })}
                />
              )}>
              <Box
                dangerouslySetInnerHTML={textHtml} />

              {answers}
            </Section>
          );
        }).reverse()
      }
    </Section>
  );
};

// NSV13 - objective status
const PageObjectives = (props, context) => {
  const { act, data } = useBackend(context);
  const statusMap = {
    0: {
      color: 'average',
      icon: 'square-o',
      statusText: 'W TOKU',
    },
    1: {
      color: 'good',
      icon: 'check-square-o',
      statusText: 'WYKONANE',
    },
    2: {
      color: 'bad',
      icon: 'window-close-o',
      statusText: 'NIEUDANE',
    },
    3: {
      color: 'good',
      icon: 'check-square-o',
      statusText: 'WYKONANE',
    },
  };

  return (
    <Section fill scrollable title="Status misji">
      {!data.announced_objectives && (
        <>
          Oczekuj na przydział zadań misji.
        </>
      ) || (
        <>
          {data.mission_briefing}<br /><br />
          <Section title="Rozgłos">
            {data.notoriety}
          </Section>
          <Section title="Cele">
            {Object.keys(data.objectives).map((key, newCurrent) => {
              let value = data.objectives[key];
              let status = statusMap[value.status] || statusMap[0];
              return (
                <tr key={value.brief}>
                  <td>
                    <Icon name={status.icon} mx={0.5} />
                  </td>
                  <Box
                    as="td"
                    color={status.color}
                    px={0.5}
                    nowrap>
                    {status.statusText}
                  </Box>
                  <Box
                    as="td"
                    px={0.5}>
                    {value.brief}
                  </Box>
                </tr>
              );
            })}
          </Section>
        </>
      )}
    </Section>
  );
};

const ConditionalTooltip = (props, context) => {
  const {
    condition,
    children,
    ...rest
  } = props;

  if (!condition)
  {
    return children;
  }

  return (
    <Tooltip {...rest}>
      {children}
    </Tooltip>
  );
};

export const CommunicationsConsole = (props, context) => {
  const { act, data } = useBackend(context);
  const {
    authenticated,
    authorizeName,
    canLogOut,
    emagged,
    hasConnection,
    page,
    canBuyShuttles,
  } = data;

  return (
    <Window
      width={800}
      height={550}
      theme={emagged ? "syndicate" : undefined}>
      <Window.Content>
        {authenticated ? (
          <Stack fill>
            <Stack.Item width="40%">
              {(canLogOut || !authenticated)
                ? (
                  <Section title="Uwierzytelnianie">
                    <Button
                      fluid
                      ellipsis
                      icon={authenticated ? "sign-out-alt" : "sign-in-alt"}
                      tooltip={authenticated && authorizeName ? authorizeName : undefined}
                      content={authenticated ? `Wyloguj${authorizeName ? ` (${authorizeName})` : ""}` : "Zaloguj"}
                      color={authenticated ? "bad" : "good"}
                      onClick={() => act("toggleAuthentication")}
                    />
                  </Section>
                )
                : null}

              {!!authenticated && <PageMain />}
            </Stack.Item>
            <Stack.Item width="60%">
              <Stack vertical fill>
                <Stack.Item>
                  <Section title="Menu" fitted>
                    <Tabs>
                      <Tabs.Tab fluid
                        icon="desktop"
                        selected={page===STATE_CHANGING_STATUS}
                        onClick={() => act("setState", { state: STATE_CHANGING_STATUS })}>
                        Wyświetlacze
                      </Tabs.Tab>

                      <Tabs.Tab fluid
                        icon="envelope-o"
                        selected={page===STATE_MESSAGES}
                        onClick={() => act("setState", { state: STATE_MESSAGES })}>
                        Wiadomości
                      </Tabs.Tab>

                      {(canBuyShuttles !== 0) && (
                        <ConditionalTooltip
                          condition={canBuyShuttles !== 1}
                          content={canBuyShuttles}>
                          <Tabs.Tab fluid
                            icon="shopping-cart"
                            selected={page===STATE_BUYING_SHUTTLE}
                            onClick={() => act("setState",
                              { state: STATE_BUYING_SHUTTLE }
                            )}>
                            Kup prom
                          </Tabs.Tab>
                        </ConditionalTooltip>
                      )}

                      <Tabs.Tab fluid
                        icon="dot-circle-o"
                        selected={page===STATE_OBJECTIVES}
                        onClick={() => act("setState", { state: STATE_OBJECTIVES })}>
                        Cele
                      </Tabs.Tab>
                    </Tabs>
                  </Section>
                </Stack.Item>
                <Stack.Item grow position="relative">
                  {!!authenticated && (
                    page === STATE_BUYING_SHUTTLE && <PageBuyingShuttle />
                    || page === STATE_CHANGING_STATUS && <PageChangingStatus />
                    || page === STATE_MESSAGES && <PageMessages />
                    || page === STATE_OBJECTIVES && <PageObjectives />
                    || <Box>Strona niezaimplementowana: {page}</Box>
                  )}
                </Stack.Item>
              </Stack>
            </Stack.Item>
          </Stack>
        ) : (
          <Flex
            height="100%"
            width="100%"
            justify="center"
            align="center">
            <Section title="Uwierzytelnianie">
              <Button
                icon="sign-in-alt"
                content="Zaloguj"
                color="good"
                onClick={() => act("toggleAuthentication")}
                fluid
              />
            </Section>
          </Flex>
        )}

        {!hasConnection && <NoConnectionModal />}
      </Window.Content>
    </Window>
  );
};
