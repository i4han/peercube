
global.cube = require 'cubesat' if !Meteor?

c1 = cube.Cube()

width  = 375
height = 667
box    = width / 5
top    = 22
bottom = 44
swipe  = 22
pic_top    = top + box
pic_height = height - (pic_top + bottom)


c1.add cube.Module('layout'
).template(->
   cube.Head @,
      html.META @,
         name:    'viewport'
         content: 'width=device-width initial-scale=1.0, user-scalable=no'
      html.TITLE @, Sat.setting.public.title
   ionic.Body @,
      ionic.NavBar  @, class: 'bar-positive'
      ionic.NavView @, blaze.Include @, 'yield'
      blaze.Include @, 'tabs'
).onStartup(->
   # FB.init appId: Sat.setting.public.fbAppId, xfbml: false, version: 'v2.3', status: true
   style$('.bar-subfooter').set bottom:48, height: 62
   #style$('.range input::-webkit-slider-thumb::after')
   #   .set backgroundColor: '#387ef5', left: 28, width: 1000, top: 13, padding: 0, height: 2
).close()


c1.add cube.Module('tabs'
).template(->
   ionic.Tabs @, _tabs: '*-icon-top',
      blaze.Each   @, 'tabs', =>
         ionic.Tab @, title: '{label}', path: '{name}', iconOff: '{icon}', iconOn: '{icon}'
).helpers(->
   tabs: -> 'chat learn feed achieve progress'.split(' ').map (a) -> Sat.module[a].property
).close()


c1.add cube.Module('achieve'
).properties(->
   icon: 'android-star-outline'
   path: 'achieve'
).template(->
   cube.Template [v, _] = cube.View(@),
      v.title   'Achieve'
      v.ionListContent '',
         v.Each 'items', =>
            time = cube.lookup @, 'time'
            ionic.Item @, buttonRight: true,
               html.H2 @, '{content}'
               html.P  @, if time then '{title} {content} due {time}' else '{title} {content}'
               html.BUTTON   @, _button: '* *-positive',
                  ionic.Icon @, icon: 'android-arrow-dropright'
      v.ionSubfooterButton id: 'facebook', 'login with facebook'
).helpers(->
   items: -> [
      {title:'Mathmatics', content:'quiz 1', time: 'tomorrow'}
      {title:'English', content:'speech'}
      {title:'Science', content:'team project'}
      {title:'Social Studies', content:'interview'}
      {title:'English', content:'writing'}
      {title:'Art', content:'dance video'}
   ]
).events(->
).close('achieve')


c1.add cube.Module('progress'
).properties(->
   icon: 'ribbon-b'
   path: 'progress'
).template(->
   cube.Template [v, _] = cube.View(@),
      v.title _.property.label
      v.ionListContent   '',
         v.ionDivider    'Mathmatics 4'
         v.ionItemLabelRange    'subject 1', local: 'distance',  min: '0',  max: '200', value: '140', '', '5/7 completed'
         v.ionDivider    'English 4'
         v.ionItemLabelRange    'subject 2', local: 'distance',  min: '0',  max: '200', value: '200', '', '9/9 completed'
         v.ionItemLabelRange    'subject 3', local: 'distance0',  min: '0',  max: '200', value: '60', '', '1/3 completed', true
         v.ionDivider    'Science 5'
         v.ionItemLabelRange    'subject 4', local: 'distance',  min: '0',  max: '200', value: '180', '', '7/8 completed'
         v.ionDivider    'Social Studies 4'
         v.ionItemLabelRange    'subject 5', local: 'distance',  min: '0',  max: '200', value: '160', '', '4/5 completed', true
).styles(->
   'local_agefrom::-webkit-slider-thumb::after':  backgroundColor: '#387ef5', left: 28, width: 1000, top: 13, padding: 0, height: 2
   'local_agefrom::-webkit-slider-thumb::before': height: 0
   'local_ageto::-webkit-slider-thumb::before':   height: 2.001
   _sstar: color: '#cbcb0f', width: 20, height: 20, position: 'absolute', top: 0, right: 2, display: 'inline'
   _barstar: position: 'absolute', top: 0, right: 40
   _range: position: 'absolute', top: 0, right: 30
   'local_distance::-webkit-slider-thumb': width: 0, boxShadow: 'none'
   'local_distance0::-webkit-slider-thumb': width: 0, boxShadow: 'none'
   'local_distance2::-webkit-slider-thumb': width: 0, boxShadow: 'none'
).helpers(->
   go:    -> Session.get 'go'
   login: -> Session.get 'loginStatus'
).events(->
   'touchend #logout': -> facebookConnectPlugin.logout (->
         Router.go 'profile'
      ), (e) -> console.log 'logout error', e
   'change #hello': (evnt) => console.log $('#hello').prop('checked')
).onCreated(->
   _ = __.module @
   _.style$ageFrom = style$(_.local('#agefrom') + '::-webkit-slider-thumb::after')
   _.style$ageTo   = style$(_.local('#ageto')   + '::-webkit-slider-thumb::before')
).onRendered(->
   _ = __.module @
   @$('#online').prop('checked', true)
   @$to = @$to or _.$ '#ageto'
   @$from = @$from or _.$ '#agefrom'
   _.unit = (_.$('#agefrom').width() - 28) / (80 - 18)
   @$from.on 'input', (evt) =>
      if (val = evt.target.value) > (to = @$to.val()) then @$to.val(val)
      else _.rangeSync val, to
   @$to.on 'input', (evt) =>
      if (val = evt.target.value) < (from = @$from.val()) then @$from.val(val)
      else _.rangeSync from, val
).fn(
   rangeSync: (from, to) ->
      @style$ageFrom.set width: (to - from - 1) * @unit
      @style$ageTo  .set width: width = (to - from - 1) * @unit, left: -width
).close('progress')


c1.add cube.Module('facebook').template(-> '').close()


c1.add cube.Module('abc').template(-> html.P @, 'ABC').close()
c1.add cube.Module('def').template(-> html.P @, 'DEF').close()

c1.add cube.Module('chat'
).properties(->
   icon: 'chatbubbles'
   path: 'chat'
   hash: '0fc7da9b30f3e2c7'
).template(-> [
   part.title  @, 'Chat'
   html.DIV    @, class: 'content',
      html.DIV @, class: 'content-padded', local: 'chat',
         blaze.Each   @, 'chats', => [
            html.IMG  @, class: 'chatid', src: '/students/{id}.jpg'
            (=>
              text = cube.lookup @, 'text'
              id = cube.lookup @, 'id'
              console.log '#', id
              side = if 'Evan' is id then 'me' else 'you'
              if text.match /\.(jpg|jpeg|png|gif)$/ then html.IMG @, _chat: "* *img *-#{side}", src: text
              else if text.match /^https:\/\/www\.youtube.com\/watch/ then html.IFRAME @, width: '400', height: '225', src: '{text}', frameborder: '0', ''
              else html.DIV(@, id: '{id}', _chat: "* *-#{side} *-text", '{text}'))()
            html.BR()]
   ionic.SubfooterBar @, html.INPUT @, local: 'input0', type: 'text'
   ]
   # https://www.youtube.com/watch?v=69dpAdpx1dk
   # <iframe width="560" height="315" src="https://www.youtube.com/embed/69dpAdpx1dk" frameborder="0" allowfullscreen></iframe>
).styles(->
   _chat:     display: 'inline-block', maxWidth: 400, color: 'white'
   _chatid:   display: 'inline-block', height: 40
   _chatimg:  display: 'inline-block', maxWidth: 400, marginTop: 3
   _chatMe:   backgroundColor: '#33bb5f'
   _chatYou:  backgroundColor: '#ef6655'
   _chatText: padding: '6px 8px', borderRadius: 16, marginTop: 4
   _chatRead: color: 'black'
   local_chat:    $fixedBottom: bottom * 2 + 22
   local_input0:  $box: ['100%', 33], $mp:0, border: 0
).helpers(->
   chats: -> db.Chats.find {}
   side:  -> 'me'
).events(->
   'keypress {local #input0}': (e) =>
      if e.keyCode == 13 and text = (Jinput = $(@local '#input0')).val()
         Jinput.val ''
         Meteor.call 'says', 'Evan', text
).close('chat')


c1.add cube.Module('chosen'
).template(->
   html.DIV @, class: 'chosen',
      blaze.Each @, 'chosen', =>
         html.DIV @, _chosen: '*-container', id: "chosen-{id}",
            html.IMG @, id: "chosen-box-{id}", width: box, src: Session.get('chosen-box-' + cube.lookup @, 'id')
            console.log cube.lookup @, 'id'
).styles(->
   _chosen: display: 'flex', flexDirection: 'row', $box: ['100%', box]
   _chosenContainer: flexGrow: 1, float: 'left', $box: [box, box], zIndex: 200,  border: 3, overflowY: 'hidden'
).helpers(-> chosen: [0..4].map (i) -> id: i
).close()

do ->
   icon_index = 0
   index = 0
   next     = -> console.log 'next'
   setImage = (id, i) -> Session.set 'img-photo-id', Matches[i].public_ids[0]
   pass     = (J) -> J.animate top: '+=1000', 600, -> J.remove() ; next()
   touchStart = (e) -> $(e.target).switchClass 'photo-front', 'photo-touched', 100
   touchEnd   = (e) -> switch
      when e.target.y > pic_top + swipe then push() and pass   $(e.target)
      when e.target.y < pic_top - swipe then push() and choose $(e.target)
      else $(e.target).switchClass 'photo-touched', 'photo-front', 100, ->  $(e.target).animate top: box, 100

   choose = (J) ->
      iconTop = $('.chosen').offset().top
      console.log 'choose', icon_index, box, box * icon_index
      J.animate top: 0, width: box, left:box * icon_index, clip: 'rect(0px, 75px, 75px, 0px)', 500, ->
         J.switchClass 'photo-touched', 'photo-icon', 300
         Session.set 'chosen-box-' + icon_index++, J.attr 'src'
         J.remove()
         next()

   push = =>
      Jfront = $ '#photo-' + ++index
      Jfront
         .switchClass('photo-back', 'photo-front', 0, -> $('#photo-' + (index + 1)).css left: 0)
         .after(HTML.toHTML html.IMG @, id:'photo-' + (index + 1), _photo: '* *-back', src: @photoUrl index + 1)
         .draggable(axis: 'y')
         .on('touchstart', touchStart)
         .on('touchend',   touchEnd)

   c1.add cube.Module('feed',
   ).properties(->
      path: '/'
      icon: 'clipboard'
   ).template(-> console.log 'PART', part ; [
      part.title  @, 'Feed'
      html.DIV    @, class: 'content',
         html.DIV @, class: 'content-padded', local: 'learn',
            ionic.List @,
               html.BR()
               html.BR()
               html.DIV @, class: 'list',
                  html.LI @, class: 'item',
                     html.IMG @, src: 'http://faculty.wwu.edu/vawter/physicsnet/Topics/Vectors/Gifs/Vectors03.gif'
                     html.H2 @, 'Mathmatics: Sin and Cos'
                     html.P @, 'Research project due tomorrow.'
                  html.LI @, class: 'item',
                     html.H2 @, 'Laura posted a new study 1 hour ago'
                     html.P @, 'Go explore.'
                  html.LI @, class: 'item item-left',
                     html.IMG @, width: '50px', src: 'http://www.rantlifestyle.com/wp-content/uploads/2014/03/pizza_slice-601400031.jpg'
                     html.H2 @, 'Hot lunch on Wednesday'
                     html.P @, 'Choose your Pizza.'
                  html.LI @, class: 'item',
                     html.H2 @, 'Mathmatics quiz 1 due tomorrow'
                     html.P @, 'Go Achieve and finish your quiz when you are ready.'
                  html.LI @, class: 'item',
                     html.IMG @, width: '50px', src: '/students/Rick.jpg'
                     html.H2 @, 'Looking for team?'
                     html.P @, 'Rick is looking for teammate for Science project 2.'
      ]
   ).onRendered(->
   ).onDestroyed(->
   ).styles(->
         _photo:        width: width, background: 'white', overflow: 'hidden'
         _photoIcon:    zIndex:  20, width: box, top: top, clip: 'rect(0px, 75px, 75px, 0px)'
         _photoFront:   zIndex:  10, position: 'absolute'
         _photoBack:    zIndex: -10, position: 'absolute'
         _photoTouched: zIndex:  1000, position: 'absolute', width: width - 1, $photoCard: ''
   ).close('feed')

do ->
   uploadPhoto = (uri) ->
      (ft = new FileTransfer()).upload uri, Settings.upload, ((r) -> console.log 'ok', r
      ), ((r) -> console.log 'err', r
      ), __.assign options = new FileUploadOptions(), o =
         fileKey:  'file'
         fileName: uri[uri.lastIndexOf('/') + 1..]
         mimeType: 'image/jpeg'
         chunkedMode: true
         params: id: 'isaac'             #ft.onprogress (r) -> console.log r
   upload = (url) ->
      resolveLocalFileSystemURL url, ((entry) ->
         entry.file ((data) -> console.log('data', data) or uploadPhoto l = data.localURL), (e) -> console.log e
      ), (e) -> console.log 'resolve err', e

   c1.add cube.Module('learn'
   ).properties(->
      icon: 'lightbulb'
      path: 'learn'
   ).template(-> [
         part.title @, 'Learn'
         html.DIV    @, class: 'content', scroll: '',
            html.DIV @, class: 'content-padded', local: 'learn',
               ionic.List @,
                  html.BR()
                  html.BR()
                  html.DIV @, class: 'list card',
                     html.DIV @, class: 'item item-divider', 'Discuss today'
                     html.DIV @, class: 'item item-avatar',
                        html.IMG @, src: '/students/Evan.jpg'
                        html.H2 @, 'Evan J Blackmore'
                        html.P @, 'November 05, 2015'
                     html.DIV @, class: 'item item-body',
                        html.IMG @, class: 'full-image', width: 160, height: 100, src: 'http://31.media.tumblr.com/7bc330e4c7e6e3515a98888dc00ef3e7/tumblr_nk27bex09A1tlppcdo1_1280.gif'
                        html.P @, 'This is example. This is example. This is example. This is example.'
                        html.B @, '{like} likes'
                     html.DIV @, class: 'item tabs tabs-secondary tabs-icon-left',
                        html.A @, class: 'tab-item', id: 'like',
                           html.I @, class: 'icon ion-thumbsup'
                           'like'
                        html.A @, class: 'tab-item',
                           html.I @, class: 'icon ion-chatbox'
                           'comment'
                        html.A @, class: 'tab-item',
                           html.I @, class: 'icon ion-share'
                           'share'
                     html.DIV @, class: 'item item-avatar',
                        html.IMG @, src: '/students/Laura.jpg'
                        html.H4 @, 'Laura Kim'
                        html.P @, 'Good read.'
                  html.DIV @, class: 'list card',
                     html.DIV @, class: 'item item-divider', 'Explore by Wednesday'
                     html.DIV @, class: 'item item-avatar',
                        html.IMG @, src: '/students/Laura.jpg'
                        html.H2 @, 'Laura Phifier'
                        html.P @, 'November 05, 2015'
                        html.H3 @, 'open'
                     html.DIV @, class: 'item item-body',
                        html.IMG @, class: 'full-image', src: 'http://31.media.tumblr.com/7bc330e4c7e6e3515a98888dc00ef3e7/tumblr_nk27bex09A1tlppcdo1_1280.gif'
                        html.P @, 'This is example. This is example. This is example. This is example.'
                     html.DIV @, class: 'item tabs tabs-secondary tabs-icon-left',
                        html.A @, class: 'tab-item', id: 'like',
                           html.I @, class: 'icon ion-thumbsup'
                           'like'
                        html.A @, class: 'tab-item',
                           html.I @, class: 'icon ion-chatbox'
                           'comment'
                        html.A @, class: 'tab-item',
                           html.I @, class: 'icon ion-share'
                           'share'
                     html.DIV @, class: 'item item-avatar',
                        html.IMG @, src: '/students/Laura.jpg'
                        html.H2 @, 'Laura Kim'
                        html.P @, 'Good read.'

      ]
   ).onRendered(->
   ).events(->
      'touchend #like': -> console.log 'ok'
   ).close('learn')



c1.add cube.Parts ->
   title:        (_, v) -> blaze.Include _, 'contentFor', headerTitle: '', html.H1 _, class: 'title', v
   $btnBlock:    (v) -> _button: '* *-block', id: v
   $mp:          (v) -> margin: v, padding: v
   $tabItem:     (v) -> class: 'tab-item', href: v, dataIgnore: 'push'
   $box:         (a) -> width: a[0], height: a[1]
   $subfooter:   (v) -> _bar: '* *-standard *-footer-secondary', _: v
   $fixedTop:    (v) -> position: 'fixed', top: v
   $fixedBottom: (v) -> position: 'fixed', bottom: v
   $photoCard:   (v) -> background: 'white', borderRadius: 2, padding: v or '8px 6px', boxShadow: '1px 1px 5px 1px'


module.exports = c1 if !Meteor?

###


         html.P     @, id: 'hw',  'hello world!'
         blaze.If   @, 'go',
            => html.P @, 'ok go'
            => html.P @, 'oops. no go'
         cube.Switch  @,
            Session.get('a') is 1, => html.P @, 'alpha'
            Session.get('a') is 2, => html.P @, 'beta', '{login}'
            Session.get('a') is 3, => blaze.Include @, Session.get('b') or 'abc'
            Session.get('a') is 4, => html.P @, 'delta'
            => html.P @, 'somthing else'

style$('.range input::-webkit-slider-thumb::after')
   .set backgroundColor: '#387ef5', left: 28, width: 1000, top: 13, padding: 0, height: 2
style$('.range input::-webkit-slider-thumb::after').set('left', '28px')
style$('.range input::-webkit-slider-thumb::after').set('width', '1000px')
style$('.range input::-webkit-slider-thumb::after').set('top', '13px')
style$('.range input::-webkit-slider-thumb::after').set('padding', '0')
style$('.range input::-webkit-slider-thumb::after').set('height', '2px')


###
