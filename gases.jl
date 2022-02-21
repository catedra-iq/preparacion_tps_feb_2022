using Unitful 

const p_atm = 764.9u"Torr" |> x -> uconvert(u"atm",x) 
const altura_solo = 9u"Torr"|> x -> uconvert(u"atm",x) 
const Tₐ = 299.0u"K"
const T₀ = 273.16u"K"
const P₀ = 1.0u"atm"
const cociente = p_atm/altura_solo

struct Medida{T}
	peso_aire :: T
	peso_pr :: T 
	peso_co2 :: T
	peso_agua :: T
end

parte_de_arriba(M::Medida) = M.peso_aire - (cociente*M.peso_pr)
vacio_alternativo(M::Medida) = (M.peso_aire - (cociente*M.peso_pr)) / (1 - cociente)
vacio_normal(M::Medida) = M.peso_pr
masa_co2_normal(M::Medida) = M.peso_co2 - vacio_normal(M) 
masa_co2_alternativo(M::Medida) = M.peso_co2 - vacio_alternativo(M)
masa_agua(M::Medida) = (M.peso_agua - vacio_normal(M)) |> ustrip |> x -> x*u"ml"
δ_normal(M::Medida) = masa_co2_normal(M) / masa_agua(M)   
δ_alternativo(M::Medida) = masa_co2_alternativo(M) / masa_agua(M)   

function a_cntp(δ::R , Tₐ::S,T₀::S, P₀::T, Pₐ::U) where {R,S,T,U <: Quantity}
	(δ*Tₐ*P₀)/(Pₐ*T₀)
end

struct Calculo
	medida :: Medida
	δ_normal 
	δ_alternativo
	function Calculo(M::Medida)
		δ_normal = masa_co2_normal(M) / masa_agua(M) |> δ -> a_cntp(δ, Tₐ, T₀,P₀, p_atm)  |> δ -> uconvert(u"g/L", δ) |> δ -> round(δ, digits = 3)
		δ_alternativo = masa_co2_alternativo(M) / masa_agua(M) |> δ -> a_cntp(δ, Tₐ, T₀,P₀, p_atm) |> δ -> uconvert(u"g/L", δ) |> δ -> round(δ, digits = 3)
		new(M,δ_normal, δ_alternativo)
	end
end


function parse_and_print(C::Calculo)
	"Densidad sin corregir $(C.δ_normal), con corrección $(C.δ_alternativo)"
end


function parse_and_print(V::Vector{Calculo})
	for (n,field) ∈  enumerate(V)
		println("Medida $n : $(parse_and_print(field))")
	end
end




#1
peso_lleno_1 = 148.88u"g"
peso_vacio_1 = 148.23u"g"
peso_co2_falopa = 149.15u"g"
ampolla_co2_llena = 149.06u"g"
peso_agua=657.9u"g"



# 2

peso_lleno_2 = 209.48u"g"
altura_vacio_2 = 9u"Torr"
peso_vacio_2 = 208.85u"g"
ampolla_co2_llena_2 = 209.81u"g"
peso_agua_2 =762.8u"g"





medida_1 = Medida(peso_lleno_1, peso_vacio_1, ampolla_co2_llena,peso_agua)
medida_2 = Medida(peso_lleno_2, peso_vacio_2, ampolla_co2_llena_2, peso_agua_2)


parse_and_print([Calculo(medida_1),Calculo(medida_2)]) 
