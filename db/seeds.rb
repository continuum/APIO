# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rails db:seed command (or created alongside the database with db:setup).
VALID_SCHEMA_OBJECT = '{
  "type": "object",
  "required": [
    "name"
  ],
  "properties": {
    "name": {
      "type": "string"
    },
    "age": {
      "type": "integer",
      "format": "int32",
      "minimum": 0
    }
  }
}'

VALID_SPEC = '{
    "swagger": "2.0",
    "info": {
        "version": "0.0.0",
        "title": "Swagger Test"
    },
    "paths": {
        "/persons": {
            "get": {
                "description": "Gets `Person` objects.\nOptional query param of **size** determines\nsize of returned array\n",
                "parameters": [
                    {
                        "name": "size",
                        "in": "query",
                        "description": "Size of array",
                        "required": true,
                        "type": "number",
                        "format": "double"
                    }
                ],
                "responses": {
                    "200": {
                        "description": "Successful response",
                        "schema": {
                            "title": "ArrayOfPersons",
                            "type": "array",
                            "items": {
                                "title": "Person",
                                "type": "object",
                                "properties": {
                                    "name": {
                                        "type": "string"
                                    },
                                    "single": {
                                        "type": "boolean"
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
    }
}'

puts 'Deleting all...'
SchemaVersion.delete_all
Schema.delete_all
ServiceVersion.delete_all
Service.delete_all
SchemaCategory.delete_all
Role.delete_all
Organization.delete_all
User.delete_all

puts 'Seeding Organizations...'
[
  {
    name: 'Servicio de Impuestos Internos',
    initials:'SII'
  },
  {
    name: 'Ministerio de Salud',
    initials: 'MINSAL'
  }
].each do |org|
  Organization.create!(org)
end

puts 'Seeding Users...'
[
  {
    rut: '22.222.222-1',
    sub: '1',
    id_token: 'ASDF',
    name: 'Perico'
  },
  {
    rut: '33.333.333-1',
    sub: '3',
    id_token: 'BSDF',
    name: 'Catalo'
  }
].each do |user|
  u = User.new(user)
  u.can_create_schemas = false
  o = Organization.find_by(initials: "MINSAL")
  u.roles.new(organization: o, name: "Schema Admin")
  if '1'.equal?(u.sub)
    u.roles.new(organization: o, name: "Agreement Signer")
  else
    o = Organization.find_by(initials: "SII")
    u.roles.new(organization: o, name: "Agreement Checker")
  end
  u.save!
end

puts 'Creating schema categories...'
[
  "Datos Personales",
  "Configuracion Regional",
  "Vehiculos",
  "Propiedades"
].each do |category_name|
  SchemaCategory.create!(name: category_name)
end

puts 'Seeding Schemas...'
[
  {
      schema_category: SchemaCategory.find_by(name: "Datos Personales"),
      name: 'Schema 1',
      spec_file: StringIO.new(VALID_SCHEMA_OBJECT)
  },
  {
      schema_category: SchemaCategory.find_by(name: "Vehiculos"),
      name: 'Schema 2',
      spec_file: StringIO.new(VALID_SCHEMA_OBJECT)
    },
    {
      schema_category: SchemaCategory.find_by(name: "Propiedades"),
      name: 'Schema 3',
      spec_file: StringIO.new(VALID_SCHEMA_OBJECT)
    },
    {
      schema_category: SchemaCategory.find_by(name: "Propiedades"),
      name: 'Schema 3 Registro Nacional de Esquemas definición basal número 40 articulo 29',
      spec_file: StringIO.new(VALID_SCHEMA_OBJECT)
    }
].each do |schema|
  Schema.create!(schema)
end
puts 'Generate 40 Schemas...'
(1..40).each do |i|
  name = 'Schema Numero ' + i.to_s
  Schema.create!(
      schema_category: SchemaCategory.find_by(name: "Vehiculos"),
      name: name,
      spec_file: StringIO.new(VALID_SCHEMA_OBJECT)
    )
end

puts 'Seeding SchemaVersions...'
[
  {
    spec_file: StringIO.new(VALID_SCHEMA_OBJECT),
    schema: Schema.find_by(name: 'Schema 1'),
  },
  {
    spec_file: StringIO.new(VALID_SCHEMA_OBJECT),
    schema: Schema.find_by(name: 'Schema 1')
  },
  {
    spec_file: StringIO.new(VALID_SCHEMA_OBJECT),
    schema: Schema.find_by(name: 'Schema 3')
  }
].each do |version|
  SchemaVersion.create!(version)
end

puts 'Generate 30 SchemaVersions for First Schema...'
(1..30).each do |i|
  SchemaVersion.create!(spec_file: StringIO.new(VALID_SCHEMA_OBJECT),
    schema: Schema.find_by(name: 'Schema 1'))
end

puts 'Seeding Services'
[
  {
    name: 'Service 1',
    organization: Organization.find_by(initials:'SII'),
    public: true
  },
  {
    name: 'Service 2',
    organization: Organization.find_by(initials:'SII'),
    public: true
  },
  {
    name: 'Service 3',
    organization: Organization.find_by(initials:'MINSAL'),
    public: true
  },
  {
    name: 'Servicio especial de interoperabilidad del Estado de Chile Decreto 158.950 del 29 de mayo',
    organization: Organization.find_by(initials:'MINSAL'),
    public: true
  }
].each do |service|
  Service.create!(service)
end

puts 'Create 25 Services...'
(1..25).each do |i|
  name= 'Servicio Nuevo Nº' + i.to_s
  Service.create!(name: name, organization: Organization.find_by(initials:'MINSAL'),
    public: true)
end

puts 'Seeding ServiceVersions...'
[
  {
    spec_file: StringIO.new(VALID_SPEC),
    service: Service.find_by(name: 'Service 1'),
    user: User.find_by(name: 'Catalo')
  },
  {
    spec_file: StringIO.new(VALID_SPEC),
    service: Service.find_by(name: 'Service 1'),
    user: User.find_by(name: 'Catalo')
  },
  {
    spec_file: StringIO.new(VALID_SPEC),
    service: Service.find_by(name: 'Service 1'),
    user: User.find_by(name: 'Catalo')
  },
  {
    spec_file: StringIO.new(VALID_SPEC),
    service: Service.find_by(name: 'Service 2'),
    status: ServiceVersion.statuses[:rejected],
    user: User.find_by(name: 'Catalo')
  },
  {
    spec_file: StringIO.new(VALID_SPEC),
    service: Service.find_by(name: 'Service 2'),
    user: User.find_by(name: 'Catalo')
  },
  {
    spec_file: StringIO.new(VALID_SPEC),
    service: Service.find_by(name: 'Service 3'),
    user: User.find_by(name: 'Perico')
  }
].each do |version|
  ServiceVersion.create!(version)
end

puts 'Create 60 Service Versions for first Service...'
(1..60).each do |i|
  ServiceVersion.create!(
    spec_file: StringIO.new(VALID_SPEC),
    service: Service.find_by(name: 'Service 1'),
    user: User.find_by(name: 'Catalo')
    )
end
