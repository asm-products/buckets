_ = require 'underscore'

module.exports =
  render: ->
    # Defer to ensure view is fully rendered
    _.defer =>
      return if @disposed

      # Automatically focus the first visible input (on non-touch devices)
      $firstField = @$('.form-control:visible').eq(0)
      $firstField.focus() unless Modernizr.touch or $firstField.val()

      # Prep slugs
      @$('.input-slug').each (i, el) ->
        $slug = $(el)
        $input = $slug.prev()

        $inputs = $slug.parent().find('input')

        unless $input.is(':focus')
          $slug.css display: 'none'

        closeTimeout = null
        $inputs.focus ->
          $slug.slideDown 80
          clearTimeout closeTimeout if closeTimeout
        $inputs.blur -> closeTimeout = setTimeout ->
          $slug.slideUp 80
        , 50

  formParams: ->
    # Uses jQuery formParams, but don't try to convert number values to numbers, etc.
    @$el.formParams no

  submit: (promise) ->
    @$btn = @$('.ladda-button').ladda()
    @$btn?.ladda 'start'

    promise.always(
      @$btn?.ladda 'stop'
    ).fail(
      _.bind(@renderServerErrors, @)
    )

  renderServerErrors: (res) ->

    # First let's get rid of the old ones
    @clearFormErrors()

    if errors = res?.responseJSON?.errors
      _.each errors, (error) =>
        if error.type is 'required' or error.message is 'required'
          message = '<span class="label label-danger">Required</span>'
        else
          message = error.message

        @$ """[name="#{error.path}"]"""
          .closest '.form-group'
          .find('.help-block').remove().end()
          .addClass 'has-error'
          .append """
            <span class="help-block">#{message}</span>
          """

      @$('.has-error').eq(0).find('[name]').eq(0).focus()

  clearFormErrors: ->
    @$('.help-block').remove()
    @$('.has-error').removeClass('has-error')
