import { Controller } from '@hotwired/stimulus'

export default class extends Controller {
  static targets = [ 'degreeSubjectContainer', 'degreeSubject', 'degreeStagesContainer' ]

  connect() {
    const radioButtons = this.degreeStagesContainerTarget.querySelectorAll('input[type="radio"]')
    const checked = Array.from(radioButtons).find(r => r.checked)
    if (checked) { this.toggleDegreeSubjectContainer(checked) }
  }

  degreeStageSelected(e) {
    this.toggleDegreeSubjectContainer(e.target)
  }

  toggleDegreeSubjectContainer(radioButton) {
    const requiresSubject = JSON.parse(radioButton.dataset.requiresSubject)
    const options = this.degreeSubjectTarget.options
    const valueForNoDegree = this.degreeSubjectTarget.dataset.valueForNoDegree
    const optionForNoDegree = Array.from(options).find(o => o.value == valueForNoDegree)
    const inputForAutoComplete = this.degreeSubjectContainerTarget.querySelector('input[name="' + this.degreeSubjectTarget.name.replace("]", "_raw]") +'"]')

    this.degreeSubjectContainerTarget.hidden = !requiresSubject

    if (optionForNoDegree) {
      optionForNoDegree.hidden = requiresSubject
      optionForNoDegree.selected = requiresSubject ? false : 'selected'
    } else if (inputForAutoComplete && !requiresSubject) {
      inputForAutoComplete.value = "";
    }
    }
  }
}
