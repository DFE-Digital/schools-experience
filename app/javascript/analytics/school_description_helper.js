import { sendGAEvent } from 'analytics/send_ga_event';

const descriptionToggleEvent = (e) => {
    let value = e.currentTarget['open'] ? 'shown' : 'hidden';
    sendGAEvent('school-onboarding', 'toggle-school-description', value);
};

const descriptionSummary = document.querySelector('details');

export { descriptionSummary, descriptionToggleEvent };
