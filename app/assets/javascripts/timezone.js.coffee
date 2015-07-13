$(".hidden.timezone").ready ->
  $(".hidden.timezone").val(jstz.determine().name())
