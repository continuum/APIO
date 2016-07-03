class SchemasController < ApplicationController

  def index
    @categories = SchemaCategory.all
    @schemas = Schema.all
  end

  def new
    return unless user_signed_in?
    if current_user.can_create_schemas
      @schema = Schema.new
      @categories = SchemaCategory.all
    else
      redirect_to schemas_path, notice: 'no tiene permisos suficientes'
    end
  end

  def create
    @schema = Schema.new(schema_params)
    if @schema.save
      @schema.create_first_version(current_user)
      redirect_to [@schema, @schema.schema_versions.first], notice: 'Nuevo Esquema creado correctamente'
    else
      flash.now[:error] = "No se pudo crear el esquema"
      render action: "new"
    end
  end

  def search
    @text_search = params[:text_search]
    @schemas = Schema.search(params[:text_search])
  end

  private

  def schema_params
    params.require(:schema).permit(:schema_category_id, :name, :spec_file)
  end

  def set_schema
    @schema = Schema.where(name: params[:name]).take
  end
end
