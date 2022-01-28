import { Application } from 'stimulus'
import SearchController from 'search_controller.js'

describe('SearchController', () => {
  beforeAll(() => registerController())

  const generateForm = (content = '', checked = true, hidden = false) => {
    return `<form id="form" action="/path" method="get" data-search-target="form" data-action="change->search#performSearch">
      <input id="checkbox-1-field" type="checkbox" name="checkbox1" value="1"${checked ? ' checked' : ''}>
      <input id="checkbox-2-field" type="checkbox" name="checkbox2" value="2"${checked ? ' checked' : ''}>
      <input id="checkbox-3-field" type="checkbox" name="checkbox3" value="3"${checked ? ' checked' : ''}>
      <button id="search-button" data-search-target="submit" type="submit"${hidden ? ' class="hidden"' : ''}>Search</button>
      ${content}
    </form>`
  }

  const responseSearchResults = '<div id="search-results">response results</div>'
  const responseForm = generateForm('response form', false, true)

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
    global.history.replaceState = jest.fn()
  }

  const mockGtag = () => {
    window.gtag = jest.fn();
  };

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
              <span class="facet-tag" data-search-target="tag">
                <span class="facet-tag__text">Checkbox 1 Tag</span>
                <button id="checkbox-1-tag-button" data-action="search#removeTag" data-key="checkbox" data-value="1">X</button>
              </span>
            </div>
          </div>
          <div id="group-2" class="facet-tags__group">
            <strong>Group 2</strong>
            <div id="checkbox-2-tag" class="facet-tags__wrapper">
              <span class="facet-tags__preposition">and</span>
              <span class="facet-tag" data-search-target="tag">
                <span class="facet-tag__text">Checkbox 2 Tag</span>
                <button id="checkbox-2-tag-button" data-action="search#removeTag" data-key="checkbox" data-value="2">X</button>
              </span>
            </div>
            <div class="facet-tags__wrapper">
              <span id="checkbox-3-tag-preposition" class="facet-tags__preposition">or</span>
              <span class="facet-tag" data-search-target="tag">
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

  describe('when supported', () => {
    beforeEach(() => {
      mockFetch()
      mockHistory()
      setBody()
      mockGtag()
    })

    it('hides the search button', () => {
      const searchButton = document.getElementById('search-button')
      expect(searchButton.classList).toContain('hidden')
    })

    it('displays the tag buttons', () => {
      const tags = document.body.querySelectorAll('.facet-tag')
      tags.forEach(tag => expect(tag.classList).toContain('interactive'))
    })

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
        expect(history.replaceState).toHaveBeenCalledWith({}, document.title, '/path?checkbox1=1&checkbox2=2&checkbox3=3')
      })

      it('sends a page view to gtag', () => {
        expect(window.gtag).toHaveBeenCalledWith('set', 'page_path', '/path?checkbox1=1&checkbox2=2&checkbox3=3');
        expect(window.gtag).toHaveBeenCalledWith('event', 'page_view');
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

  describe('when unsupported', () => {
    beforeEach(() => {
      delete global.fetch;
      delete global.URLSearchParams;

      setBody()
    })

    it('does not hide the search button', () => {
      const searchButton = document.getElementById('search-button')
      expect(searchButton.classList).not.toContain('hidden')
    })

    it('does not display the tag buttons', () => {
      const tags = document.body.querySelectorAll('.facet-tag')
      tags.forEach(tag => expect(tag.classList).not.toContain('interactive'))
    })

    it('does not make a request when changing the form', () => {
      mockFetch()

      const form = document.getElementById('form')
      form.dispatchEvent(new Event('change'))

      expect(fetch).not.toHaveBeenCalled()
    })
  })
})
