Spine = require('spine')

class Post extends Spine.Model
  @configure 'Post' , "title" , "link" , "link"
  @extend Spine.Model.Ajax

  @current: null

  validate: =>
    return Post.validate(@)
    
  @validate: (post) =>
    #TODO: Could use REGEX for title
    msg = []
    msg.push field: "link"  , error: "The link is not valid" if !Post.validateURL(post.link)
    msg.push field: "title" , error: "The Title should like a sentence" if !post.title or post.title.length < 5 or post.title.indexOf(" ") == -1
    return if msg.length > 0 then msg else ""

   @validateURL: (textval) ->
     urlregex = new RegExp("^(http|https|ftp)\://([a-zA-Z0-9\.\-]+(\:[a-zA-Z0-9\.&amp;%\$\-]+)*@)*((25[0-5]|2[0-4][0-9]|[0-1]{1}[0-9]{2}|[1-9]{1}[0-9]{1}|[1-9])\.(25[0-5]|2[0-4][0-9]|[0-1]{1}[0-9]{2}|[1-9]{1}[0-9]{1}|[1-9]|0)\.(25[0-5]|2[0-4][0-9]|[0-1]{1}[0-9]{2}|[1-9]{1}[0-9]{1}|[1-9]|0)\.(25[0-5]|2[0-4][0-9]|[0-1]{1}[0-9]{2}|[1-9]{1}[0-9]{1}|[0-9])|([a-zA-Z0-9\-]+\.)*[a-zA-Z0-9\-]+\.(com|edu|gov|int|mil|net|org|biz|arpa|info|name|pro|aero|coop|museum|[a-zA-Z]{2}))(\:[0-9]+)*(/($|[a-zA-Z0-9\.\,\?\'\\\+&amp;%\$#\=~_\-]+))*$");
     return urlregex.test(textval)

   @fromJSON: (objects) ->
     return unless objects

     if typeof objects is 'string'
       objects = JSON.parse(objects)

     objects = objects.results if objects.results      

     if Spine.isArray(objects)
       for object in objects
         if object.objectId
           object.id = object.objectId
           delete object.objectId
       (new @(value) for value in objects)
     else
       objects.id = objects.objectId if objects.objectId
       new @(objects)

   toJSON: () ->
     atts = this.attributes();
     return atts;


module.exports = Post