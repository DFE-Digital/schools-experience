import {Controller} from "stimulus";
import flatpickr from "flatpickr";
import '../stylesheets/calendar.scss';

export default class extends Controller {
  static targets = [
    "input",
    "tagsWrapper"
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
      onReady: (selectedDates, dateString, instance) => {
        this.#addTags(selectedDates, instance)
      },
      onChange: (selectedDates, dateString, instance) => {
        this.#addTags(selectedDates, instance)
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

  #addTags = (selectedDates, instance) => {
    this.#clearTags();
    const sortedDates = this.#sortDates(selectedDates)

    sortedDates.forEach((date) => {
      const tag = document.createElement("div")
      tag.classList.add("tag")
      tag.textContent = new Date(date).toLocaleDateString("en-GB", {day: "numeric", month: "short", year: "numeric"})
      tag.addEventListener("click", (event) => this.#removeDate(event.target.textContent, instance, selectedDates))
      this.tagsWrapperTarget.appendChild(tag)
    })
  }

  #removeDate = (dateString, instance, selectedDates) => {
    const dateToRemove = new Date(dateString);
    instance.clear()

    const restOfDates = selectedDates.filter(date => {
      return date.getTime() !== dateToRemove.getTime()
    })

    this.#addTags(restOfDates, instance)
    instance.setDate(restOfDates)
    this.#jumpToMonth(instance, dateToRemove.getMonth())
  }

  #jumpToMonth = (instance, month) => {
    instance.changeMonth(month, false)
  }

  #clearTags = () => {
    this.tagsWrapperTarget.innerHTML = null
  }

  #sortDates = (dates) => {
    return dates.sort((a, b) => a.getTime() - b.getTime());
  }
}
