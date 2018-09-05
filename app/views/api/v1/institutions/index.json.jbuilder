json.institutions do
  json.partial! 'institution', collection: @institutions, as: :institution
end
