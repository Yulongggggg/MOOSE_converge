vertical_stress = 20e6
k = 1
inner_pressure = 1000
#-------------
youngs_modulus_1 = 20e9
poissons_ratio_1 = 0.1
youngs_modulus_2 = 20e9
poissons_ratio_2 = 0.1

[Mesh]
  file = heterogeneous_r2.msh
[]

[GlobalParams]
  displacements = 'disp_x disp_y'
[]

[Variables] #Block for the main variable (displacement), for auxiliary variables using [AxuVariables]
  [disp_x] # Define the interpolation functions
    order = FIRST
    family = LAGRANGE
  []
  [disp_y] # Define the interpolation functions
    order = FIRST
    family = LAGRANGE
  []
[]

[Functions]
  [vs_func]
    type = ParsedFunction
    expression = 'vertical_stress '
    symbol_names = 'vertical_stress'
    symbol_values = '${vertical_stress}'
  []
  [hs_func]
    type = ParsedFunction
    expression = 'k * vertical_stress '
    symbol_names = 'k vertical_stress'
    symbol_values = '${k} ${vertical_stress}'
  []
  [ip_func]
    type = ParsedFunction
    expression = 'inner_pressure '
    symbol_names = 'inner_pressure'
    symbol_values = '${inner_pressure}'
  []
[]

[Physics]
  [SolidMechanics]
    [QuasiStatic]
      [all]
        strain = SMALL
        add_variables = true
        generate_output = 'stress_xx stress_xy stress_yy '
        material_output_family = 'MONOMIAL'
        material_output_order = 'FIRST'
        block = 'Block1 Block2'
      []
    []
  []
[]

[BCs]
  [top_stress]
    type = Pressure
    variable = disp_y
    boundary = 'Top'
    function = 'vs_func' # pa
  []
  [bottom_stress]
    type = Pressure
    variable = disp_y
    boundary = 'Bottom'
    function = 'vs_func' # pa
  []
  [right_stress]
    type = Pressure
    variable = disp_x
    boundary = 'Right'
    function = hs_func # pa
  []
  [left_stress]
    type = Pressure
    variable = disp_x
    boundary = 'Left'
    function = hs_func # pa
  []
  [CavityPressure_x]
    type = Pressure
    boundary = 'Cavity'
    displacements = 'disp_x disp_y'
    variable = disp_x
    function = '${inner_pressure}' # pa
  []
  [CavityPressure_y]
    type = Pressure
    boundary = 'Cavity'
    displacements = 'disp_x disp_y'
    variable = disp_y
    function = '${inner_pressure}' # pa
  []
[]

[ICs]
  [ic_ux]
    type = ConstantIC
    variable = disp_x
    value = 0.0
  []
  [ic_uy]
    type = ConstantIC
    variable = disp_y
    value = 0.0
  []
[]

[Materials]
  [elasticity_tensor_1]
    type = ComputeIsotropicElasticityTensor
    youngs_modulus = '${youngs_modulus_1}' # Pa
    poissons_ratio = '${poissons_ratio_1}'
    block = 'Block1'
  []
  [linear_stress_1]
    type = ComputeLinearElasticStress
    block = 'Block1'
  []
  [elasticity_tensor_2]
    type = ComputeIsotropicElasticityTensor
    youngs_modulus = '${youngs_modulus_2}' # Pa
    poissons_ratio = '${poissons_ratio_2}'
    block = 'Block2'
  []
  [linear_stress_2]
    type = ComputeLinearElasticStress
    block = 'Block2'
  []
[]

[Executioner] # for non-linear problem, please use transient executioner and incremental loading. PS. Anna told me this so it's correct
  type = Steady
  solve_type = NEWTON
[]

[Outputs]
  [out]
    type = Exodus
    # file_base = '../../elasticity_output/homogenous/1'
  []
[]

# Mohr-Coulomb: 'materials/CappedMohrCoulombStressUpdate' or 'userobjects/SolidMechanicsPlasticMohrCoulomb'


