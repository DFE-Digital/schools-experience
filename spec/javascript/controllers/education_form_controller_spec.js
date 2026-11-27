import { Application } from '@hotwired/stimulus'
import EducationFormController from 'education_form_controller.js'

describe('EducationFormController', () => {
  const noDegree = "I don't have a degree and am not studying for one"
  const finalYear = 'Final year'

  const setBody = () => {
    document.body.innerHTML = `
      <form data-controller="education-form">
        <section data-education-form-target="degreeStagesContainer">
          <input type="radio" name="stage" id="no-degree" value="${noDegree}"
            data-action="click->education-form#degreeStageSelected"
            data-requires-subject="false">
          <input type="radio" name="stage" id="final-year" value="${finalYear}"
            data-action="click->education-form#degreeStageSelected"
            data-requires-subject="true">
        </section>
        <section data-education-form-target="degreeSubjectContainer">
          <input type="hidden" class="nojs-flag" value="true">
          <div class="hide-with-javascript"><input type="text" name="nojs"></div>
          <div class="show-with-javascript" style="display: none">
            <label for="degree-subject">Degree subject</label>
            <select id="degree-subject" name="education[degree_subject]"
              class="enable-with-javascript" disabled
              data-education-form-target="degreeSubject"
              data-value-for-no-degree="Not applicable"
              aria-describedby="degree-subject-hint">
              <option value="Not applicable">Not applicable</option>
              <option value="Maths">Maths</option>
            </select>
            <input type="text" name="education[degree_subject_raw]" value="Maths">
          </div>
        </section>
      </form>`
  }

  let application

  beforeAll(() => {
    application = Application.start()
    application.register('education-form', EducationFormController)
  })

  beforeEach(async () => {
    setBody()
    await Promise.resolve()
  })

  const subjectContainer = () =>
    document.querySelector('[data-education-form-target="degreeSubjectContainer"]')
  const select = () => document.getElementById('degree-subject')
  const noDegreeOption = () => select().querySelector('option[value="Not applicable"]')

  describe('connecting', () => {
    it('enables the JavaScript experience and removes the fallback', () => {
      expect(document.querySelector('.nojs-flag').value).toEqual('false')
      expect(document.querySelector('.hide-with-javascript').style.display).toEqual('none')
      expect(document.querySelector('.show-with-javascript').style.display).toEqual('block')
      expect(select().disabled).toBe(false)
    })

    it('keeps the select labelled and described for assistive technology', () => {
      expect(document.querySelector('label[for="degree-subject"]').textContent).toEqual('Degree subject')
      expect(select().getAttribute('aria-describedby')).toEqual('degree-subject-hint')
    })
  })

  describe('choosing a stage without a degree', () => {
    beforeEach(() => document.getElementById('no-degree').click())

    it('hides the subject choices', () => {
      expect(subjectContainer().hidden).toBe(true)
    })

    it('selects and reveals the no degree option', () => {
      expect(noDegreeOption().hidden).toBe(false)
      expect(noDegreeOption().selected).toBe(true)
    })
  })

  describe('choosing a stage with a degree', () => {
    beforeEach(() => {
      document.getElementById('no-degree').click()
      document.getElementById('final-year').click()
    })

    it('shows the subject choices', () => {
      expect(subjectContainer().hidden).toBe(false)
    })

    it('hides the no degree option', () => {
      expect(noDegreeOption().hidden).toBe(true)
    })
  })

  describe('when no degree option is not available', () => {
    it('clears the autocomplete input', () => {
      noDegreeOption().remove()
      document.getElementById('no-degree').click()

      expect(
        document.querySelector('input[name="education[degree_subject_raw]"]').value
      ).toEqual('')
    })
  })
})
