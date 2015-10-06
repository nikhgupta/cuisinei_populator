#= require active_admin/base
#= require select2
$ ->
  $(".tagselect").select2
    tags: true
    tokenSeparators: [',']

  $(".has_many_add").on 'click', ->
    setTimeout (->
      $(".tagselect").select2
        tags: true
        tokenSeparators: [',']
    ), 150
