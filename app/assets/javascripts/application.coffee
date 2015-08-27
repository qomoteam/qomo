#= require jquery
#= require patch
#= require jquery-ui
#= require jquery-layout
#= require aui
#= require jsPlumb

#= require workspaces.coffee
#= require_self

AJS.toInit ->
  AJS.$('.select2').auiSelect2()


