RootView = require 'root-view'
SearchInBufferView = require 'search-in-buffer/lib/search-in-buffer'

describe 'SearchInBufferView', ->
  [subject, editor] = []
  beforeEach ->
    window.rootView = new RootView

  describe "with no editor", ->
    beforeEach ->
      subject = SearchInBufferView.activate()

    describe "when search-in-buffer:display-find is triggered", ->
      it "attaches to the root view", ->
        subject.showFind()
        expect(subject.hasParent()).toBeTruthy()
        expect(subject.resultCounter.text()).toEqual('')

  describe "with an editor", ->
    beforeEach ->
      rootView.open('sample.js')
      rootView.enableKeymap()
      editor = rootView.getActiveView()
      editor.attached = true #hack as I cant get attachToDom() to work

      subject = SearchInBufferView.activate()

    describe "when search-in-buffer:display-find is triggered", ->
      it "attaches to the root view", ->
        editor.trigger 'search-in-buffer:display-find'
        expect(subject.hasParent()).toBeTruthy()

    describe "option buttons", ->
      beforeEach ->
        editor.trigger 'search-in-buffer:display-find'
        editor.attachToDom()

      it "clicking an option button toggles its enabled class", ->
        subject.toggleRegexOption()
        expect(subject.searchModel.getOption('regex')).toEqual true
        expect(subject.regexOptionButton).toHaveClass('enabled')

    describe "running a search", ->
      beforeEach ->
        editor.trigger 'search-in-buffer:display-find'

        editor.attachToDom()
        subject.miniEditor.textInput 'items'
        subject.miniEditor.trigger 'core:confirm'

      it "shows correct message in results view", ->
        expect(subject.resultCounter.text()).toEqual('1 of 6')
        expect(editor.getSelectedBufferRange()).toEqual [[1, 22], [1, 27]]

      it "editor deletion is handled properly", ->
        editor.remove()
        expect(subject.resultCounter.text()).toEqual('')

        # should not die on new search!
        subject.miniEditor.textInput 'items'

      # FIXME: when the cursor moves, I want this to pass. cursor:moved never
      # gets called in tests
      xit "removes the '# of' when user moves cursor", ->
        editor.setCursorBufferPosition([10,1])
        editor.setCursorBufferPosition([12,1])

        waits 1000
        runs ->
          expect(subject.resultCounter.text()).toEqual('6 found')


