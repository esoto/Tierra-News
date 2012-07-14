Spine = require('spine')

Post = require('models/post')
class Posts extends Spine.Controller

  events:
    "click li" : "onItemClick"

  constructor: ->
    super
    Post.bind "refresh create" , @render
        
  render: =>    
    posts = Post.all()
    @html require("views/posts/item")(posts)

  onItemClick: (e)  =>
    e.preventDefault()
    $('.popable').popover('hide')
    target = $(e.target)
    id = target.attr "data-id"
    post = Post.find id
    Post.current = post
    Spine.trigger "changePost" , post
    return false

module.exports = Posts
