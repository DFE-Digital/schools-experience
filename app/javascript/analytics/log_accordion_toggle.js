import { sendGAEvent } from 'analytics/send_ga_event';

const logAccordionToggle = (name, section, state) => {
  sendGAEvent(name, section, state);
};

export { logAccordionToggle };
