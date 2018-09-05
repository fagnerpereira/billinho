json.institution do
  json.extract! @institution, :id, :name, :cnpj, :kind
end
