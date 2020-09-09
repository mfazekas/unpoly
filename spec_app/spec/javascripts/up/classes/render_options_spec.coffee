describe 'up.RenderOptions', ->

  describe '.preprocess()', ->

    it 'sets global defaults', ->
      givenOptions = {}
      options = up.RenderOptions.preprocess(givenOptions)
      expect(options.hungry).toBe(true)
      expect(options.keep).toBe(true)
      expect(options.source).toBe(true)
      expect(options.fail).toBe('auto')

    describe 'with { navigate: true }', ->

      it 'sets defaults appropriate for user navigation', ->
        givenOptions = { navigate: true }
        options = up.RenderOptions.preprocess(givenOptions)

        expect(options.solo).toBe(true)
        expect(options.feedback).toBe(true)
        expect(options.fallback).toBe(true)
        expect(options.history).toBe('auto')
        expect(options.peel).toBe(true)
        expect(options.reveal).toBe(true)
        expect(options.transition).toBe('navigate')

    describe 'with { navigate: false }', ->

      it 'sets additional defaults appropriate to programmatic fragment changes', ->
        givenOptions = { navigate: false }
        options = up.RenderOptions.preprocess(givenOptions)

        expect(options.history).toBe(false)

    it 'overrides defaults with given options', ->
      givenOptions = { navigate: false, hungry: false, source: '/other-source' }
      options = up.RenderOptions.preprocess(givenOptions)

      expect(options.hungry).toBe(false)
      expect(options.source).toBe('/other-source')

    describe 'with { preload: true }', ->

      it 'disables features inappropriate when preloading, regardless of given options', ->
        givenOptions = { preload: true, solo: true, confirm: true, feedback: true, url: '/path' }
        options = up.RenderOptions.preprocess(givenOptions)

        expect(options.url).toBe('/path')
        expect(options.solo).toBe(false)
        expect(options.confirm).toBe(false)
        expect(options.feedback).toBe(false)

  describe '.deriveFailOptions()', ->
    
    # In the code flow in up.fragment, options are first preprocessed and then
    # failOptions are derived. Mimic this behavior here.
    preprocessAndDerive = (options) ->
      options = up.RenderOptions.preprocess(options)
      options = up.RenderOptions.deriveFailOptions(options)
      options
    
    it 'sets global defaults', ->
      givenOptions = {}
      options = preprocessAndDerive(givenOptions)

      expect(options.hungry).toBe(true)
      expect(options.keep).toBe(true)
      expect(options.source).toBe(true)
      expect(options.fail).toBe('auto')
      
    describe 'with { navigate: true }', ->

      it 'sets defaults appropriate for user navigation', ->
        givenOptions = { navigate: true }

        options = preprocessAndDerive(givenOptions)

        expect(options.solo).toBe(true)
        expect(options.feedback).toBe(true)
        expect(options.fallback).toBe(true)
        expect(options.history).toBe('auto')
        expect(options.peel).toBe(true)
        expect(options.reveal).toBe(true)
        expect(options.transition).toBe('navigate')

    describe 'with { navigate: false }', ->

      it 'sets additional defaults appropriate to programmatic fragment changes', ->
        givenOptions = { navigate: false }
        options = preprocessAndDerive(givenOptions)

        expect(options.history).toBe(false)

    it 'inherits shared keys from success options', ->
      givenOptions = { confirm: 'Really?', origin: document.body, history: true }
      options = preprocessAndDerive(givenOptions)

      expect(options.confirm).toBe('Really?')
      expect(options.origin).toBe(document.body)
      expect(options.history).toBe(true)

    it 'does not inherit non-shared keys from success options', ->
      givenOptions = { mode: 'popup', reveal: '.reveal' }
      options = preprocessAndDerive(givenOptions)

      expect(options.layer).toBeUndefined()
      expect(options.reveal).toBeUndefined()

    it 'overrides defaults with given fail-prefixed options', ->
      givenOptions = { failTarget: '.fail', failSource: '/fail-source', failMode: 'popup' }
      options = preprocessAndDerive(givenOptions)

      expect(options.target).toBe('.fail')
      expect(options.mode).toBe('popup')
      expect(options.source).toBe('/fail-source')

  describe '.fixLegacyHistoryOption()', ->

    it 'moves an URL string from the { history } option (legacy syntax) to the { location } option (next syntax)', ->
      options = { history: '/foo' }
      warnSpy = spyOn(up.legacy, 'warn')

      up.RenderOptions.fixLegacyHistoryOption(options)

      expect(options).toEqual { history: 'auto', location: '/foo' }
      expect(warnSpy).toHaveBeenCalled()

    it 'does nothing for { history: "auto" }', ->
      options = { location: '/foo' }
      warnSpy = spyOn(up.legacy, 'warn')

      up.RenderOptions.fixLegacyHistoryOption(options)

      expect(options).toEqual { location: '/foo' }
      expect(warnSpy).not.toHaveBeenCalled()
