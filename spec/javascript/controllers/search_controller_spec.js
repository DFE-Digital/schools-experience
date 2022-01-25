import { Application } from 'stimulus'
import SearchController from 'search_controller.js'

describe('SearchController', () => {
  beforeAll(() => registerController())
  beforeEach(() => {
    mockFetch()
    mockHistory()
    setBody()
  })

  const generateForm = (content = '', checked = true) => {
    return `<form id="form" action="/path" method="get" data-search-target="form" data-action="change->search#performSearch">
      <input id="checkbox-1-field" type="checkbox" name="checkbox1" value="1"${checked ? ' checked' : ''}>
      <input id="checkbox-2-field" type="checkbox" name="checkbox2" value="2"${checked ? ' checked' : ''}>
      <input id="checkbox-3-field" type="checkbox" name="checkbox3" value="3"${checked ? ' checked' : ''}>
      ${content}
    </form>`
  }

  const responseSearchResults = '<div id="search-results">response results</div>'
  const responseForm = generateForm('response form', false)

  const mockFetch = () => {
    global.fetch = jest.fn(() => {
      // Ensure it shows the loading message; there's no easy/clean
      // way of having this as a separate test.
      const loading = document.getElementById('loading')
      expect(loading.classList).toContain('active')

      return Promise.resolve({
        text: () => Promise.resolve(`${responseForm}${responseSearchResults}`),
      })
    })
  }

  const mockHistory = () => {
    document.title = 'Title'
    global.history.pushState = jest.fn()
  }

  const setBody = () => {
    document.body.innerHTML = `
      <div data-controller="search" data-search-results-id-value="search-results" data-search-form-id-value="form">
        ${generateForm()}

        <div id="search-results"></div>

        <div id="loading" data-search-target="loading">Loading</div>

        <div class="facet-tags">
          <div id="group-1" class="facet-tags__group">
            <strong>Group 1</strong>
            <div class="facet-tags__wrapper">
              <span class="facet-tags__preposition">and</span>
              <span class="facet-tag">
                <span class="facet-tag__text">Checkbox 1 Tag</span>
                <button id="checkbox-1-tag-button" data-action="search#removeTag" data-key="checkbox" data-value="1">X</button>
              </span>
            </div>
          </div>
          <div id="group-2" class="facet-tags__group">
            <strong>Group 2</strong>
            <div id="checkbox-2-tag" class="facet-tags__wrapper">
              <span class="facet-tags__preposition">and</span>
              <span class="facet-tag">
                <span class="facet-tag__text">Checkbox 2 Tag</span>
                <button id="checkbox-2-tag-button" data-action="search#removeTag" data-key="checkbox" data-value="2">X</button>
              </span>
            </div>
            <div class="facet-tags__wrapper">
              <span id="checkbox-3-tag-preposition" class="facet-tags__preposition">or</span>
              <span class="facet-tag">
                <span class="facet-tag__text">Checkbox 3 Tag</span>
                <button data-action="search#removeTag" data-key="checkbox" data-value="3">X</button>
              </span>
            </div>
          </div>
        </div>
      </div>
    `
  }

  const registerController = () => {
    const application = Application.start()
    application.register('search', SearchController)
  }

  describe('changing the form', () => {
    beforeEach(() => {
      const form = document.getElementById('form')
      form.dispatchEvent(new Event('change'))
    })

    it('performs a search', () => {
      expect(fetch).toHaveBeenCalledWith('/path?checkbox1=1&checkbox2=2&checkbox3=3')
    })

    it('hides the loading message', () => {
      const loading = document.getElementById('loading')
      expect(loading.classList).not.toContain('active')
    })

    it('updates the search results', () => {
      const results = document.getElementById('search-results')
      expect(results.outerHTML).toEqual(responseSearchResults)
    })

    it('updates the search form', () => {
      const results = document.getElementById('form')
      expect(results.outerHTML).toEqual(responseForm)
    })

    it('updates the page history', () => {
      expect(history.pushState).toHaveBeenCalledWith({}, document.title, '/path?checkbox1=1&checkbox2=2&checkbox3=3')
    })
  })

  describe('when a search has already occurred', () => {
    beforeEach(() => {
      Object.defineProperty(window, 'location', {
        configurable: true,
        value: { pathname: '/path', search: '?old=term' },
      });
    })

    describe('when the user presses the back button', () => {
      beforeEach(() => window.dispatchEvent(new Event('popstate')))

      it('performs a search', () => {
        expect(fetch).toHaveBeenCalledWith('/path?old=term')
      })
    })
  })

  describe('removing a tag', () => {
    beforeEach(() => {
      const checkbox1TagButton = document.getElementById('checkbox-1-tag-button')
      checkbox1TagButton.dispatchEvent(new Event('click'))
    })

    it('clears the associated form element', () => {
      const checkbox1Input = document.getElementById('checkbox-1-field')
      expect(checkbox1Input.checked).toEqual(false)
    })

    describe('when it is the last tag in the group', () => {
      it('removes the group', () => {
        const group1 = document.getElementById('group-1')
        expect(group1).toBeNull()
      })
    })

    describe('when it is not the last tag in the group', () => {
      beforeEach(() => {
        const checkbox2TagButton = document.getElementById('checkbox-2-tag-button')
        checkbox2TagButton.dispatchEvent(new Event('click'))
      })

      it('removes the tag element', () => {
        const checkbox2Tag = document.getElementById('checkbox-2-tag')
        expect(checkbox2Tag).toBeNull()
      })

      it('ensures the new first preposition in the group is cleared', () => {
        const checkbox3TagPreposition = document.getElementById('checkbox-3-tag-preposition')
        expect(checkbox3TagPreposition.textContent).toEqual('')
      })
    })

    it('performs a search', () => {
      expect(fetch).toHaveBeenCalledWith('/path?checkbox2=2&checkbox3=3')
    })
  })
})
