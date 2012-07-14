require('lib/setup')

Spine = require('spine')

Header = require("controllers/parts/header")
Posts = require("controllers/parts/posts")


UserRegistrationModal = require("modals/userRegistration")
GeneralModal   = require("modals/generalModal")
PostModal   = require("modals/postModal")

CurrentUser = require('models/currentUser')
Post = require('models/post')


class App extends Spine.Controller
  @extend Spine.Controller.ModalController

  elements:
    ".header" : "header"
    "ul.posts" : "postsList"

  constructor: ->
    super    
    @setupModal()
    
    new Header(el: @header)
    new Posts(el: @postsList) if @postsList

    @setupCurrentUser()
    Post.refresh @posts if @posts

    @loadFromName(@current) if @current
    Spine.bind "changePost" , @loadPost
    window.onpopstate = @onHashChange

  onHashChange: =>
    link = history?.state

  loadFromName: (id) =>
    post = Post.exists id
    if post
      Post.current = post
      @loadPost( post )
    else
      window.history.pushState( "/" , "" , "/")
    

  loadPost: (post ) =>
    #window.disqus_identifier = post.uniqueUrl
    #window.disqus_url = "http://#{Spine.location}/#{post.uniqueUrl}";
    alert "would load #{post.title}"
    window.history.pushState( post.id , "" , post.id )
    #@resetDisquis(post.uniqueUrl)

  setupCurrentUser: =>
    CurrentUser.bind "save" , CurrentUser.afterSave
    CurrentUser.fetch()

    if @authData
      CurrentUser.logout()
      Spine.trigger "show_modal" , "userRegistration" , action: "create" , authData: @authData







module.exports = App
    