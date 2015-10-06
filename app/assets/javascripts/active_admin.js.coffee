#= require active_admin/base
#= require select2
# allow items to be edited which have not been saved

$ ->
  reverse = (el) -> $($(el).get().reverse())
  itemize = (el) ->
    name  = $(el).find(".item-name").val()
    cost  = $(el).find(".item-cost").val()
    tags  = $(el).find(".item-tags").val()
    html  = "<div class='item-summary'>"
    html += "<span class='name'>#{name}</strong>"
    if tags?.length > 0
      html += "<span class='tag'>#{tag}</span>" for tag in tags
    if cost?.length > 0
      html += "<span class='cost'>#{cost}</span>"
    html += "</div>"

  itemizeAndRemove = (el) ->
    html = itemize(el)
    $(".items-list").prepend("<div class='has_many_item'></div>")
    index = if $("body").hasClass("admin_namespace") then "last" else "first"
    $(".has_many_item:first:#{index}").append($(el).hide())
    $(".has_many_item:first:#{index}").append(html)
    $(".items-list .item-summary").off('click').on 'click', ->
      $(@).parent(".has_many_item").find('.has_many_fields').show => $(@).hide()

  $(".tagselect").select2
    tags: true
    tokenSeparators: [',']

  selector = $("body.active_admin.places,body.active_admin.admin_places")
  if selector.length > 0 and not selector.hasClass("index")
    # hide footer and bring actions above items entry and scroll to it
    $("#footer").hide()
    $(".actions").insertAfter(".place-details")
    $('html, body').animate { scrollTop: $(".actions").offset().top }, 1000

    $('.has_many_add').after("<div class='items-list'></div>")

    # convert already added items (which dont have errors) to divs
    # $(".has_many_fields:visible").filter((index) ->
    #   $(@).find(".field_with_errors").length == 0
    # ).each -> $(".has_many_add").after(itemizeAndRemove(@))
    $(".has_many_fields:visible").each -> itemizeAndRemove(@)
    $(".has_many_item").filter((index) ->
      $(@).find(".field_with_errors").length > 0
    ).each ->
      $(@).find(".has_many_fields").show()
      $(@).find(".item-summary").hide()

    # when "Add Item" is clicked, itemize current entry
    $('body').on 'has_many_add:before', (e, parent) ->
      parent.data('has_many_index', $(".items-list .has_many_item").length - 1)

    $('body').on 'has_many_add:after', (e, fieldset, parent) ->
      $(".item-name:visible:first").focus()
      $(".tagselect:visible").select2
        tags: true
        tokenSeparators: [',']
      if $(".has_many_fields:visible").length > 1 && $(".item-name:visible:first").val().length > 0
        itemizeAndRemove('.has_many_fields:visible:first')
      else
        $(".items-list").prepend("<div class='has_many_item' style='display:none'></div>")

  # # convert added items to divs

  # $(".has_many_container").on 'has_many_add:before', (parent) ->
  #   if $(".has_many_fields:visible").length > 0 && $(".item-name:visible").val().length > 0
  #     $(".item-summary:first").before(itemize(".has_many_fields:visible:first", true))
  #     $(".has_many_fields:visible:first").hide()

  # $(".has_many_container").on 'has_many_add:after', (fieldset, parent) ->
