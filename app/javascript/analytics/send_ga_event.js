const sendGAEvent = (action, label, value) => {
    if (window.ga) {
        window.ga('send', 'event', action, label, value);
    };
};

export { sendGAEvent };
