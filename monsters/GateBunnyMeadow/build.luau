--!nocheck
-- Bunny Meadow Gate (Map landmark, stage 2 gate). A VIP party-garden entrance
-- spanning the whole 64-stud run lane.
-- * Two giant velvet-rope stanchion pillars (x = +-32..44): stepped gold
--   footings, purple shafts wrapped in pink bands and gold rings, thin neon-pink
--   pinstripes, a flared gold capital and a chunky stepped gold knob finial with
--   a neon-pink gem.
-- * A purple marquee lintel with gold trim, a neon-pink pin line and rows of
--   marquee bulbs. Red velvet ropes swag from each pillar to the sign on both
--   faces, hung from gold clips.
-- * The plain pale-pink "Sign" sits in a chunky stepped gold frame ringed with
--   marquee bulbs (the map tool adds the stage name on its -Z face). The back
--   carries a pink plaque with a gold carrot.
-- * Crown: two huge white-and-pink bunny ears burst up from behind the sign, tied
--   with a big pink bow; little pink topiary bunnies-in-pots and gold stars flank them.
-- Opening: completely clear for |x| < 32, y < 19 (lintel bottom at 19.3).
-- Static Filler landmark: no scripts, no effects.
return {
	DisplayName = "Bunny Meadow Gate",
	Rarity = "Landmark",
	Filler = true,
	Element = "Bunny Meadow",
	Build = function(B, P)
		local v, cf, ang = P.v, P.cf, P.ang
		local R = "Root"

		local GOLD, GOLD_DK, GOLD_LT = "#ffc62e", "#d9961a", "#ffe27a"
		local PURP, PURP_DK, PURP_LT = "#7e3cf0", "#5b22c4", "#a874ff"
		local PINK, PINK_DK, PINK_LT = "#ff6fc4", "#e0459f", "#ffa6dc"
		local VELVET, VELVET_DK, VELVET_LT = "#c0162f", "#860c20", "#e0334c"
		local WHITE, WHITE_DK = "#fdf8fb", "#ead9e6"
		local N_PINK = "#ff4fc0"
		local BULB = "#fff3a6"
		local SIGN = "#ffe8f5"
		local HEDGE, HEDGE_DK, HEDGE_LT = "#ff8fd0", "#e86fb8", "#ffb6e2"
		local CARROT, CARROT_DK = "#ff8a1c", "#d6600c"
		local LEAF, LEAF_DK = "#5fd645", "#349a2c"
		local EYE = "#2a1840"

		local PX = 38
		local BY0, BY1 = 19.3, 25.3
		local BD = 5

		---------------------------------------------------------------- stanchion pillars
		B:sym(function(side, s)
			-- stepped gold footing (round-ish: square + 45deg square)
			B:block(R, v(12, 1.0, 11), cf(PX, 0.5, 0), GOLD_DK)
			B:block(R, v(10.6, 1.0, 10.6), cf(PX, 1.5, 0), GOLD)
			B:block(R, v(8.4, 1.0, 8.4), cf(PX, 1.6, 0, 0, 45, 0), GOLD_DK)
			B:block(R, v(9.0, 1.0, 9.0), cf(PX, 2.5, 0), GOLD_LT)
			B:block(R, v(7.6, 0.8, 7.6), cf(PX, 3.3, 0), GOLD)
			-- shaft
			local SW = 6.4
			B:block(R, v(SW, 22, SW), cf(PX, 3.6 + 11, 0), PURP)
			-- chamfer corners (darker)
			for _, cx in { -1, 1 } do
				for _, cz in { -1, 1 } do
					B:block(R, v(1.0, 22, 1.0), cf(PX + cx * (SW / 2 - 0.3), 14.6, cz * (SW / 2 - 0.3)), PURP_DK)
				end
			end
			-- pink bands
			for _, y in { 8, 15.5, 22 } do
				B:block(R, v(SW + 0.4, 2.4, SW + 0.4), cf(PX, y, 0), PINK)
				B:block(R, v(SW + 0.45, 0.4, SW + 0.45), cf(PX, y + 1.0, 0), PINK_LT)
				B:block(R, v(SW + 0.45, 0.4, SW + 0.45), cf(PX, y - 1.0, 0), PINK_DK)
			end
			-- gold rings between bands
			for _, y in { 4.6, 11.8, 18.8 } do
				B:block(R, v(SW + 0.9, 0.9, SW + 0.9), cf(PX, y, 0), GOLD)
				B:block(R, v(SW + 0.6, 0.9, SW + 0.6), cf(PX, y, 0, 0, 45, 0), GOLD_DK)
			end
			-- neon pinstripes on the 4 faces (purple sections)
			for _, seg in { { 12.7, 14.3 }, { 19.6, 20.8 } } do
				local y = (seg[1] + seg[2]) / 2
				local h = seg[2] - seg[1]
				B:block(R, v(0.35, h, SW + 0.12), cf(PX, y, 0), N_PINK, { mat = "Neon" })
				B:block(R, v(SW + 0.12, h, 0.35), cf(PX, y, 0), N_PINK, { mat = "Neon" })
			end
			-- flared capital
			B:block(R, v(7.6, 0.9, 7.6), cf(PX, 25.0, 0), GOLD_DK)
			B:block(R, v(8.6, 1.0, 8.6), cf(PX, 25.9, 0), GOLD)
			B:block(R, v(9.4, 0.7, 9.4), cf(PX, 26.75, 0), GOLD_LT)
			B:block(R, v(8.0, 0.7, 8.0), cf(PX, 26.8, 0, 0, 45, 0), GOLD_DK)
			-- chunky stepped knob finial
			B:block(R, v(3.4, 0.8, 3.4), cf(PX, 27.5, 0), GOLD_DK)
			B:block(R, v(5.0, 1.2, 5.0), cf(PX, 28.5, 0), GOLD)
			B:block(R, v(6.0, 1.6, 6.0), cf(PX, 29.9, 0), GOLD)
			B:block(R, v(5.4, 1.6, 5.4), cf(PX, 29.9, 0, 0, 45, 0), GOLD_LT)
			B:block(R, v(5.0, 1.2, 5.0), cf(PX, 31.3, 0), GOLD)
			B:block(R, v(3.2, 0.8, 3.2), cf(PX, 32.3, 0), GOLD_DK)
			B:gem(R, v(1.4, 1.4, 1.4), cf(PX, 33.1, 0, 0, 45, 0), N_PINK)
			-- highlight glints on the knob
			B:block(R, v(1.0, 0.6, 0.3), cf(PX - 1.4, 30.4, -3.05), "#fff6c8")
			B:block(R, v(1.0, 0.6, 0.3), cf(PX - 1.4, 30.4, 3.05), "#fff6c8")
			-- velvet-rope hooks (gold rings) on the inner face, front and back
			for _, f in { -1, 1 } do
				B:block(R, v(1.2, 1.6, 0.5), cf(PX - SW / 2 - 0.6, 23.2, f * 1.6), GOLD_DK)
				B:block(R, v(0.5, 0.6, 0.5), cf(PX - SW / 2 - 1.1, 22.4, f * 1.6), GOLD)
			end
			-- party garden: pink topiary cubes at the footing corners
			for _, c in { { -1, -1 }, { 1, -1 }, { -1, 1 }, { 1, 1 } } do
				local x, z = PX + c[1] * 4.8, c[2] * 4.6
				B:block(R, v(1.6, 1.6, 1.6), cf(x, 1.8, z, 0, 20, 0), HEDGE)
				B:block(R, v(1.2, 1.2, 1.2), cf(x, 3.0, z, 15, 40, 10), HEDGE_LT)
			end
		end)

		---------------------------------------------------------------- lintel
		local LY = (BY0 + BY1) / 2
		local LH = BY1 - BY0
		B:block(R, v(66, LH, BD), cf(0, LY, 0), PURP)
		B:block(R, v(66.2, 1.0, BD + 0.3), cf(0, BY0 + 0.5, 0), PURP_DK)
		B:block(R, v(67, 0.8, BD + 1.2), cf(0, BY1 + 0.3, 0), GOLD)
		B:block(R, v(67.2, 0.3, BD + 1.4), cf(0, BY1 + 0.75, 0), GOLD_LT)
		for _, f in { -1, 1 } do
			local fz = f * (BD / 2 + 0.2)
			B:block(R, v(66.2, 0.6, 0.5), cf(0, BY0 + 1.3, fz), GOLD_DK)
			B:block(R, v(66.2, 0.6, 0.5), cf(0, BY1 - 0.6, fz), GOLD_DK)
			-- neon pin line
			B:block(R, v(64, 0.3, 0.2), cf(0, LY + 0.35, f * (BD / 2 + 0.05)), N_PINK, { mat = "Neon" })
			-- pink diamond studs along the faces
			for x = 17.5, 30.5, 3.25 do
				for _, sx in { -1, 1 } do
					B:block(R, v(1.1, 1.1, 0.4), cf(sx * x, LY + 0.35, fz, 0, 0, 45), PINK)
				end
			end
			-- marquee bulbs along top/bottom gold bands
			for x = 16.5, 31.5, 1.5 do
				for _, sx in { -1, 1 } do
					B:block(R, v(0.5, 0.5, 0.35), cf(sx * x, BY0 + 1.3, f * (BD / 2 + 0.5)), BULB, { mat = "Neon" })
					B:block(R, v(0.5, 0.5, 0.35), cf(sx * x, BY1 - 0.6, f * (BD / 2 + 0.5)), BULB, { mat = "Neon" })
				end
			end
		end

		---------------------------------------------------------------- velvet rope swags (both faces)
		local function swag(x0, x1, y, sag, z)
			local n = 8
			local prev
			for i = 0, n do
				local t = i / n
				local x = x0 + (x1 - x0) * t
				local yy = y - sag * 4 * t * (1 - t)
				local p = v(x, yy, z)
				if prev then
					B:bar(R, prev, p, 0.75, 0.75, (i % 2 == 0) and VELVET or VELVET_DK)
				end
				prev = p
			end
			-- gold clips at both ends + tassel at the low point
			B:block(R, v(0.9, 0.9, 0.9), cf(x0, y, z), GOLD)
			B:block(R, v(0.9, 0.9, 0.9), cf(x1, y, z), GOLD)
			local mx = (x0 + x1) / 2
			B:block(R, v(0.6, 0.5, 0.6), cf(mx, y - sag - 0.5, z), GOLD)
			B:block(R, v(0.8, 0.9, 0.8), cf(mx, y - sag - 1.1, z), VELVET_LT)
		end
		B:sym(function()
			swag(PX - 3.7, 16.4, 23.2, 2.6, -BD / 2 - 1.2)
			swag(PX - 3.7, 16.4, 23.2, 2.6, BD / 2 + 1.2)
		end)

		---------------------------------------------------------------- sign
		local SY = 23.25
		local SZ = -BD / 2 - 1.1
		B:block(R, v(28, 5.5, 1), cf(0, SY, SZ), SIGN, { name = "Sign" })
		B:block(R, v(27, 5, 0.8), cf(0, SY, -BD / 2 - 0.35), PURP_DK)
		local FZ = SZ - 0.25
		B:block(R, v(31, 1.3, 1.6), cf(0, SY + 3.4, FZ), GOLD)
		B:block(R, v(31, 1.3, 1.6), cf(0, SY - 3.4, FZ), GOLD)
		B:block(R, v(1.5, 5.5, 1.6), cf(-14.75, SY, FZ), GOLD)
		B:block(R, v(1.5, 5.5, 1.6), cf(14.75, SY, FZ), GOLD)
		-- outer stepped rim
		B:block(R, v(32.2, 0.5, 1.2), cf(0, SY + 4.3, FZ + 0.2), GOLD_DK)
		B:block(R, v(0.6, 8.3, 1.2), cf(-15.8, SY + 0.4, FZ + 0.2), GOLD_DK)
		B:block(R, v(0.6, 8.3, 1.2), cf(15.8, SY + 0.4, FZ + 0.2), GOLD_DK)
		-- corner pink gems
		for _, x in { -14.75, 14.75 } do
			for _, y in { SY + 3.4, SY - 3.4 } do
				B:block(R, v(1.9, 1.7, 1.9), cf(x, y, FZ), GOLD_DK)
				B:block(R, v(1.0, 1.0, 0.4), cf(x, y, FZ - 0.95, 0, 0, 45), N_PINK, { mat = "Neon" })
			end
		end
		-- marquee bulbs around the frame
		for x = -12.6, 12.61, 1.8 do
			B:block(R, v(0.55, 0.55, 0.35), cf(x, SY + 3.4, FZ - 0.9), BULB, { mat = "Neon" })
			B:block(R, v(0.55, 0.55, 0.35), cf(x, SY - 3.4, FZ - 0.9), BULB, { mat = "Neon" })
		end
		for _, x in { -14.75, 14.75 } do
			for _, y in { SY - 1.2, SY, SY + 1.2 } do
				B:block(R, v(0.55, 0.55, 0.35), cf(x, y, FZ - 0.9), BULB, { mat = "Neon" })
			end
		end

		-- back plaque: pink board with a gold-trimmed carrot
		local bz = BD / 2 + 0.35
		B:block(R, v(22, 4.6, 0.5), cf(0, LY + 0.1, bz), PINK)
		B:block(R, v(23, 0.6, 0.7), cf(0, LY + 2.5, bz), GOLD)
		B:block(R, v(23, 0.6, 0.7), cf(0, LY - 2.3, bz), GOLD)
		B:block(R, v(0.6, 5.2, 0.7), cf(-11.5, LY + 0.1, bz), GOLD)
		B:block(R, v(0.6, 5.2, 0.7), cf(11.5, LY + 0.1, bz), GOLD)
		-- carrot lying along X
		local cz = bz + 0.35
		B:block(R, v(5, 2.2, 0.5), cf(-1, LY, cz), CARROT)
		B:block(R, v(3, 1.5, 0.5), cf(2.8, LY, cz), CARROT)
		B:block(R, v(1.6, 0.8, 0.5), cf(4.9, LY, cz), CARROT_DK)
		B:block(R, v(0.3, 1.0, 0.55), cf(0, LY, cz), CARROT_DK)
		B:block(R, v(0.3, 0.8, 0.55), cf(2.4, LY + 0.2, cz), CARROT_DK)
		B:block(R, v(1.6, 0.6, 0.5), cf(-4.2, LY + 0.6, cz, 0, 0, 25), LEAF)
		B:block(R, v(1.8, 0.6, 0.5), cf(-4.4, LY, cz), LEAF_DK)
		B:block(R, v(1.6, 0.6, 0.5), cf(-4.2, LY - 0.6, cz, 0, 0, -25), LEAF)

		---------------------------------------------------------------- bunny ears crown
		local EB = BY1 + 0.4 -- ear base y
		local function ear(s)
			local base = CFrame.new(s * 2.0, EB, 0.3) * ang(0, 0, -s * 32)
			local segs = { { 2.8, 1.3 }, { 3.6, 1.6 }, { 4.0, 1.7 }, { 4.0, 1.6 }, { 3.6, 1.4 }, { 2.8, 1.0 }, { 1.8, 0.7 } }
			local y = 0
			for i, sg in segs do
				local w, h = sg[1], sg[2]
				B:block(R, v(w, h + 0.05, 2.4), base * CFrame.new(0, y + h / 2, 0), (i % 2 == 0) and WHITE_DK or WHITE)
				if i >= 2 and i <= 6 then
					local iw = w - 1.5
					local col = (i % 2 == 0) and PINK or PINK_LT
					B:block(R, v(iw, h + 0.06, 0.3), base * CFrame.new(0, y + h / 2, -1.25), col)
					B:block(R, v(iw, h + 0.06, 0.3), base * CFrame.new(0, y + h / 2, 1.25), col)
				end
				y += h
			end
			-- deep-pink centre line on the inner ear
			B:block(R, v(0.5, 5.6, 0.34), base * CFrame.new(0, 4.8, -1.3), PINK_DK)
			B:block(R, v(0.5, 5.6, 0.34), base * CFrame.new(0, 4.8, 1.3), PINK_DK)
		end
		ear(1)
		ear(-1)
		-- headband the ears grow from
		B:block(R, v(10, 1.2, 3.0), cf(0, EB + 0.4, 0.3), PINK_DK)
		B:block(R, v(10.2, 0.5, 3.2), cf(0, EB + 0.95, 0.3), PINK)
		-- big bow between the ears
		local BWY = EB + 2.6
		B:block(R, v(1.8, 1.8, 1.4), cf(0, BWY, -0.9), N_PINK, { mat = "Neon" })
		for _, s in { -1, 1 } do
			B:block(R, v(2.6, 2.4, 1.2), cf(s * 1.9, BWY + 0.1, -0.9, 0, 0, s * 12), PINK)
			B:block(R, v(1.6, 1.6, 1.25), cf(s * 2.6, BWY + 0.3, -0.92, 0, 0, s * 12), PINK_LT)
			B:block(R, v(0.8, 2.0, 1.0), cf(s * 0.9, BWY - 1.6, -0.9, 0, 0, s * 20), PINK_DK)
		end
		-- back side of the bow
		B:block(R, v(5, 2.2, 1.0), cf(0, BWY, 1.5), PINK_DK)
		B:block(R, v(1.6, 1.6, 1.1), cf(0, BWY, 1.6), N_PINK, { mat = "Neon" })

		---------------------------------------------------------------- side crown: topiary bunnies in gold pots + stars
		local function topiaryBunny(x, ry)
			local base = CFrame.new(x, BY1 + 0.85, 0) * ang(0, ry, 0)
			-- gold pot
			B:block(R, v(3.2, 1.4, 3.2), base * CFrame.new(0, 0.7, 0), GOLD)
			B:block(R, v(3.6, 0.5, 3.6), base * CFrame.new(0, 1.55, 0), GOLD_DK)
			-- body + head (pink hedge)
			B:block(R, v(3.0, 2.6, 2.8), base * CFrame.new(0, 3.1, 0.1), HEDGE_DK)
			B:block(R, v(2.6, 2.2, 2.4), base * CFrame.new(0, 3.3, 0), HEDGE)
			B:block(R, v(2.4, 2.0, 2.2), base * CFrame.new(0, 5.4, -0.2), HEDGE)
			B:block(R, v(2.0, 1.6, 2.3), base * CFrame.new(0, 5.6, -0.3), HEDGE_LT)
			-- ears
			for _, k in { -1, 1 } do
				B:block(R, v(0.7, 1.6, 0.6), base * CFrame.new(k * 0.6, 7.0, -0.1) * ang(0, 0, -k * 10), HEDGE)
				B:block(R, v(0.35, 1.1, 0.65), base * CFrame.new(k * 0.6, 7.0, -0.12) * ang(0, 0, -k * 10), PINK_DK)
				-- eyes
				B:block(R, v(0.4, 0.5, 0.2), base * CFrame.new(k * 0.55, 5.8, -1.45), EYE)
			end
			B:block(R, v(0.5, 0.35, 0.2), base * CFrame.new(0, 5.2, -1.47), N_PINK)
			-- cotton tail on the back
			B:block(R, v(1.0, 1.0, 0.6), base * CFrame.new(0, 2.8, 1.6), WHITE)
		end
		topiaryBunny(-14.2, 10)
		topiaryBunny(14.2, -10)
		-- gold stars further out
		local function star(x, y, r, k)
			B:block(R, v(2.6 * k, 2.6 * k, 0.9), cf(x, y, 0, 0, 0, r), GOLD)
			B:block(R, v(2.6 * k, 2.6 * k, 0.95), cf(x, y, 0, 0, 0, r + 45), GOLD_LT)
			B:block(R, v(1.0 * k, 1.0 * k, 1.05), cf(x, y, 0, 0, 0, r), N_PINK, { mat = "Neon" })
			B:block(R, v(0.35, y - BY1 - 3.6, 0.35), cf(x, (y + BY1 + 3.6) / 2 - 0.6, 0), GOLD_DK)
		end
		B:sym(function()
			local x0, x1 = 17.0, 32.0
			local mx, w = (x0 + x1) / 2, x1 - x0
			B:block(R, v(w, 1.4, 3.4), cf(mx, BY1 + 1.6, 0), PURP_DK)
			B:block(R, v(w + 0.3, 0.4, 3.7), cf(mx, BY1 + 2.3, 0), GOLD)
			local n = 0
			for x = x0 + 1.0, x1 - 0.9, 1.9 do
				n += 1
				local h = (n % 2 == 0) and 1.9 or 1.5
				B:block(R, v(1.9, h, 2.8), cf(x, BY1 + 2.5 + h / 2, 0, 0, (n % 3) * 7, 0), (n % 2 == 0) and HEDGE or HEDGE_DK)
				if n % 2 == 0 then
					B:block(R, v(0.5, 0.5, 0.5), cf(x - 0.3, BY1 + 2.6 + h, -1.0, 0, 45, 0), WHITE)
					B:block(R, v(0.5, 0.5, 0.5), cf(x + 0.4, BY1 + 2.6 + h, 1.0, 0, 45, 0), GOLD_LT)
				end
			end
		end)
		star(-20.5, BY1 + 6.0, 10, 1)
		star(20.5, BY1 + 6.0, -10, 1)
		star(-27.5, BY1 + 5.6, -8, 0.8)
		star(27.5, BY1 + 5.6, 8, 0.8)
	end,
}
