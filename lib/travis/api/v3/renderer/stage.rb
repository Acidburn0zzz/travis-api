module Travis::API::V3
  class Renderer::Stage < ModelRenderer
    representation(:minimal, :id, :number, :name)
    representation(:standard, *representations[:minimal], :jobs)
    representation(:active, *representations[:standard])
  end
end