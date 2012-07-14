Spine   = require('spine')
$       = Spine.$
CurrentUser = require('models/currentUser')

class UserRegistrationModal extends Spine.Controller
  @extend Spine.Controller.Modal

  className: 'showUserRegistration modal'

  @type = "userRegistration"

  elements:
    ".email"    : "email"
    ".description"     : "description"
    ".alert"          : "alert"

  events:
    "click .cancel"      :   "onClose"
    "click .accept"      :   "onTwitterSubmit"

  constructor: ->
    super

    if @data.action == "create"
      @html require("views/modals/userRegistration/working")(@data.authData)
      user = CurrentUser.fromAuthData(@data.authData)
      user.ajax().create {}, { success: @onCreateSuccess  } 
    else if @data.action == "edit"
      @render()

  onCreateSuccess: =>
    @render()

  render: =>
    @html require("views/modals/userRegistration/layout_#{Spine.user.provider()}")(Spine.user)


  onTwitterSubmit: =>
    try
      #@updateFromView(Spine.user,@inputs_to_validate)
      categories = []
      Spine.user.setProviders()
      Spine.user.email = @email.val()
      Spine.user.description = @description.val()
      Spine.user.save()
      Spine.user.ajax().update( {} , { success: @onUpdateSuccess , error: @onUpdateError }  )   
      @alert.html "Se han guardado los cambios"
      @alert.addClass "alert-success"
    catch err
      @alert.addClass "alert-error"
      @alert.html require("views/errors/validationError")(err)

  onUpdateSuccess: ->
    Spine.trigger "hide_modal"

  onUpdateError: (xhr, statusText, error) =>
    @alert.addClass "alert-error"
    @alert.html require("views/errors/validationError")(err)
  
  onClose: =>
    CurrentUser.logout() if @data.authData
    Spine.trigger "hide_modal"

module.exports = UserRegistrationModal
