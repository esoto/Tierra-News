Spine   = require('spine')
$       = Spine.$

Post = require('models/post')
  
class PostModal extends Spine.Controller
  @extend Spine.Controller.Modal
  
  className: 'post modal'

  @type = "post"

  events:
    "click .cancel" : "onClose"
    "click .accept" : "onSave"
    
  elements:
    ".link"     :  "link"
    ".title"   :  "title"
    ".alert"    : "alert"

  constructor: ->
    super
    @render()
    
  doBind: =>
    Post.bind "ajaxSuccess" , @onSaveSuccess
    Post.bind "ajaxError" , @onSaveError
    
  undoBind: =>
    Post.unbind "ajaxSuccess" , @onSaveSuccess
    Post.unbind "ajaxError" , @onSaveError

  render: =>
    @html require("views/modals/postModal")(@data)

  onSave: =>
    tempPost = title: @title.val() , link: @link.val()
    post = Post.create tempPost
    if !post
      errors = Post.validate tempPost
      @addAlert("error","Error: #{errors[0].error}")
    else
      @doBind()
      @addAlert("success","The Post was Published!")

  addAlert: (cls , msg) ->
    @alert.html msg
    @alert.removeClass "alert-error"
    @alert.removeClass "alert-success"
    @alert.addClass "alert-#{cls}"

  onSaveSuccess: =>
    @undoBind()
    @onClose()

  onSaveError: (obj,xhr,error) =>
    @undoBind()
    @addClass "error" , error

  onClose: =>
    Spine.trigger "hide_modal"

module.exports = PostModal
