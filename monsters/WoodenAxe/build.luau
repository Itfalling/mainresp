-- Wooden Axe: a common starter axe, shown standing on its pommel.
-- Handle runs up Y, the blade points +X. Static model (no motion).
return {
	DisplayName = "Wooden Axe",
	Rarity = "Common",
	Element = "Tool",
	Build = function(B, P)
		local v, cf = P.v, P.cf
		local HANDLE, HANDLE_D = "#8b5a2b", "#6b4220"
		local HEAD, HEAD_L, EDGE = "#c98f4f", "#dcaa6a", "#efc98c"
		local LEATHER, LEATHER_D = "#5a3a22", "#3e2716"

		-- handle with a couple of grain strips
		B:block("Root", v(0.45, 4.7, 0.45), cf(0, 2.55, 0), HANDLE)
		B:block("Root", v(0.06, 1.6, 0.12), cf(0.24, 2.4, 0.08), HANDLE_D)
		B:block("Root", v(0.12, 1.2, 0.06), cf(-0.06, 2.9, 0.24), HANDLE_D)

		-- grip wrap + pommel
		B:block("Root", v(0.56, 1.3, 0.56), cf(0, 1.0, 0), LEATHER)
		B:block("Root", v(0.6, 0.14, 0.6), cf(0, 0.45, 0), LEATHER_D)
		B:block("Root", v(0.6, 0.14, 0.6), cf(0, 1.55, 0), LEATHER_D)
		B:block("Root", v(0.62, 0.3, 0.62), cf(0, 0.15, 0), HANDLE_D)

		-- axe head: wooden block wrapped onto the handle, stepping out to the blade
		B:block("Root", v(1.1, 1.3, 0.6), cf(0.35, 4.0, 0), HEAD)
		B:block("Root", v(0.45, 1.75, 0.5), cf(1.1, 4.0, 0), HEAD)
		B:block("Root", v(0.4, 2.15, 0.4), cf(1.5, 4.0, 0), HEAD_L)
		B:block("Root", v(0.18, 2.3, 0.3), cf(1.78, 4.0, 0), EDGE)
		-- back poll
		B:block("Root", v(0.45, 0.85, 0.55), cf(-0.4, 4.0, 0), HEAD_L)
		-- leather bindings above and below the head, and a top cap
		B:block("Root", v(0.6, 0.22, 0.6), cf(0, 3.25, 0), LEATHER)
		B:block("Root", v(0.6, 0.22, 0.6), cf(0, 4.75, 0), LEATHER)
		B:block("Root", v(0.5, 0.2, 0.5), cf(0, 5.0, 0), HANDLE_D)
	end,
}
