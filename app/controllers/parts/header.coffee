Spine = require('spine')

class Header extends Spine.Controller

  events:
    "click .publish"  : "onPublishClick"

  elements:
    "input"   : "input"

  constructor: ->
    super
        
  onPublishClick: =>
    if Spine.user
      link = @input.val()
      Spine.trigger "show_modal" , "post" , link: link
    else
      Spine.trigger "show_modal" , "general" , template: "loginTwitter" 


module.exports = Header
