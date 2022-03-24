import {Controller} from "stimulus";
import flatpickr from "flatpickr";
import '../stylesheets/calendar.scss';

export default class extends Controller {
  static targets = [
    "input"
  ];

  async connect() {
    flatpickr(".calendar", {
      inline: true,
      monthSelectorType: "static",
      locale: {
        weekdays: {
          shorthand: ["S", "M", "T", "W", "T", "F", "S"],
          longhand: []
        }
      },
      onDayCreate: (dateObject, dateString, flatpickr, dayElement) => {
        this.#addCloseButtonToSelected(dayElement)
      },
      disable: [this.#disableWeekends],
      mode: "multiple"
    });
  }

  #disableWeekends = (date) => {
    return (date.getDay() === 0 || date.getDay() === 6);
  }

  #addCloseButtonToSelected = (dayElement) => {
    if (dayElement.classList.contains("selected")) {
      const closeButton = document.createElement("span")
      closeButton.classList.add("close-button")
      dayElement.appendChild(closeButton)
    }
  }
}
