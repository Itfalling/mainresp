--!nocheck
-- Boombox Speaker Tower (Bunny Meadow decoration, medium).
-- A party stack on a little stage plate: a big purple bass cabinet, a hot-pink
-- mid cabinet with two tweeters, and a cyan boombox with a gold handle on top,
-- each stacked a little crooked for fun. Every speaker cone sits in a thin
-- neon ring and lives on its own bone so motion.luau can pulse it to the beat.
return {
	DisplayName = "Boombox Speaker Tower",
	Rarity = "Decor",
	Element = "Bunny Meadow",
	Build = function(B, P)
		local v, cf, ang = P.v, P.cf, P.ang
		local R = "Root"

		local STAGE, STAGE_LT = "#26222e", "#3a3546"
		local GOLD_LT, GOLD, GOLD_DK = "#ffe27a", "#ffc62e", "#d9961a"
		local PURP_DK, PURP, PURP_LT = "#4a1aa8", "#7e3cf0", "#a874ff"
		local PINK_DK, PINK, PINK_LT = "#c41f86", "#ff3fb4", "#ff86d4"
		local CYAN_DK, CYAN, CYAN_LT = "#0e94c0", "#16c8f0", "#72e6ff"
		local SURR, CONE, CONE_LT, CAP = "#1b1824", "#7d8499", "#aab1c4", "#2b2838"
		local GRASS, GRASS_DK = "#58c23a", "#3f9a2a"
		local N_PINK, N_CYAN, N_YELLOW = "#ff5cc8", "#4fe6ff", "#fff36a"

		------------------------------------------------------------ footing
		B:block(R, v(7.0, 0.4, 5.4), cf(0, 0.2, 0), STAGE)
		B:block(R, v(6.2, 0.1, 4.6), cf(0, 0.42, 0), STAGE_LT)
		for _, s in { -1, 1 } do
			B:block(R, v(7.2, 0.3, 0.3), cf(0, 0.25, s * 2.75), GOLD_DK)
			B:block(R, v(0.3, 0.3, 5.6), cf(s * 3.55, 0.25, 0), GOLD_DK)
		end
		-- coiled cable at the side
		B:block(R, v(1.2, 0.25, 1.2), cf(-2.6, 0.55, 1.6, 0, 20, 0), "#15121c")
		B:block(R, v(0.8, 0.25, 0.8), cf(-2.6, 0.75, 1.6, 0, 65, 0), "#15121c")
		local tufts = { { -3.9, -2.2 }, { 3.8, 2.4 }, { 4.0, -1.0 }, { -3.7, 2.8 } }
		for i, t in tufts do
			local h = 0.8 + (i % 2) * 0.4
			B:block(R, v(0.45, h, 0.45), cf(t[1], h / 2, t[2], 0, i * 27, 0), (i % 2 == 0) and GRASS or GRASS_DK)
			B:block(R, v(0.35, h * 0.6, 0.35), cf(t[1] + 0.35, h * 0.3, t[2] + 0.25, 0, i * 41, 0), GRASS_DK)
		end

		------------------------------------------------------------ helpers
		-- cabinet: body + lighter front frame + gold corner caps. Returns CF of the box centre.
		local function cabinet(C, size, body, dark, light)
			B:block(R, size, C, body)
			local w, h, d = size.X, size.Y, size.Z
			-- front frame
			B:block(R, v(w + 0.1, 0.35, 0.3), C * CFrame.new(0, h / 2 - 0.175, -d / 2 + 0.1), light)
			B:block(R, v(w + 0.1, 0.35, 0.3), C * CFrame.new(0, -h / 2 + 0.175, -d / 2 + 0.1), light)
			B:block(R, v(0.35, h - 0.3, 0.3), C * CFrame.new(w / 2 - 0.125, 0, -d / 2 + 0.1), light)
			B:block(R, v(0.35, h - 0.3, 0.3), C * CFrame.new(-w / 2 + 0.125, 0, -d / 2 + 0.1), light)
			-- side handle slots
			for _, sx in { -1, 1 } do
				B:block(R, v(0.12, 0.4, 1.2), C * CFrame.new(sx * (w / 2 + 0.03), h * 0.15, 0.2), dark)
			end
			-- gold corners
			for _, sx in { -1, 1 } do
				for _, sy in { -1, 1 } do
					for _, sz in { -1, 1 } do
						B:block(R, v(0.5, 0.5, 0.5), C * CFrame.new(sx * (w / 2 - 0.15), sy * (h / 2 - 0.15), sz * (d / 2 - 0.15)), GOLD)
					end
				end
			end
		end
		-- neon octagon ring on a face (face CF: -Z points out of the face)
		local function octRing(F, r, t, color, name)
			local side = 2 * r * math.tan(math.rad(22.5)) + t
			for k = 0, 7 do
				local a = math.rad(k * 45)
				B:block(R, v(t, side, t), F * CFrame.new(math.cos(a) * r, math.sin(a) * r, -t / 2) * ang(0, 0, k * 45), color, { mat = "Neon", name = name })
			end
		end
		-- speaker: dark surround (static) + cone on its own bone
		local function speaker(F, r, ringColor, boneName)
			local s = r * 2
			B:block(R, v(s, s * 0.72, 0.3), F * CFrame.new(0, 0, -0.1), SURR)
			B:block(R, v(s * 0.72, s, 0.3), F * CFrame.new(0, 0, -0.1), SURR)
			octRing(F * CFrame.new(0, 0, -0.2), r + 0.12, 0.2, ringColor, boneName .. "Ring")
			local bone = B:bone(boneName, "Root", F * CFrame.new(0, 0, -0.25))
			local c = r * 1.5
			-- hidden basket so a pushed-out cone never shows a gap
			B:block(bone, v(c * 0.8, c * 0.8, 0.7), F * CFrame.new(0, 0, -0.05), SURR)
			B:block(bone, v(c, c * 0.7, 0.3), F * CFrame.new(0, 0, -0.3), CONE)
			B:block(bone, v(c * 0.7, c, 0.3), F * CFrame.new(0, 0, -0.3), CONE)
			B:block(bone, v(c * 0.62, c * 0.62, 0.3), F * CFrame.new(0, 0, -0.42) * ang(0, 0, 45), CONE_LT)
			B:block(bone, v(c * 0.34, c * 0.34, 0.3), F * CFrame.new(0, 0, -0.55), CAP)
			return bone
		end

		------------------------------------------------------------ bass cabinet
		local Y0 = 0.45
		local s1 = v(5.0, 4.6, 3.6)
		local C1 = CFrame.new(0, Y0 + s1.Y / 2, 0)
		cabinet(C1, s1, PURP_DK, "#2e0f72", PURP)
		local F1 = C1 * CFrame.new(0, 0.1, -s1.Z / 2)
		speaker(F1, 1.65, N_PINK, "ConeBig")
		-- little gold logo plate
		B:block(R, v(1.0, 0.25, 0.1), C1 * CFrame.new(0, -s1.Y / 2 + 0.5, -s1.Z / 2 - 0.02), GOLD_LT)

		-- back: bass port + jack plate
		local BK = C1 * CFrame.new(0, 0.4, s1.Z / 2)
		B:block(R, v(2.2, 1.4, 0.2), BK * CFrame.new(0, 0, 0.06), SURR)
		B:block(R, v(1.4, 2.2, 0.2), BK * CFrame.new(0, 0, 0.06), SURR)
		B:block(R, v(1.6, 0.6, 0.2), C1 * CFrame.new(0, -1.5, s1.Z / 2 + 0.06), GOLD_DK)
		for i = -1, 1 do
			B:block(R, v(0.25, 0.25, 0.15), C1 * CFrame.new(i * 0.5, -1.5, s1.Z / 2 + 0.17), STAGE)
		end
		-- pixel music-note stickers on both sides
		for _, sx in { -1, 1 } do
			local S = C1 * CFrame.new(sx * (s1.X / 2 + 0.06), 0, 0) * ang(0, sx * 90, 0)
			-- in S: local X runs along the side, Y up
			B:block(R, v(0.3, 1.8, 0.14), S * CFrame.new(0.35, 0.35, 0), GOLD)
			B:block(R, v(0.9, 0.7, 0.14), S * CFrame.new(-0.1, -0.55, 0), GOLD)
			B:block(R, v(0.9, 0.35, 0.14), S * CFrame.new(0.65, 1.1, 0), GOLD)
			B:block(R, v(0.35, 0.35, 0.14), S * CFrame.new(0.95, 0.8, 0), GOLD)
		end

		------------------------------------------------------------ mid cabinet
		local s2 = v(4.2, 3.4, 3.1)
		local C2 = CFrame.new(0.15, Y0 + s1.Y + s2.Y / 2, 0.1) * ang(0, 7, 0)
		cabinet(C2, s2, PINK, PINK_DK, PINK_LT)
		local F2 = C2 * CFrame.new(-0.45, -0.05, -s2.Z / 2)
		speaker(F2, 1.2, N_CYAN, "ConeMid")
		-- two tweeters stacked at the side
		for k, dy in { 0.75, -0.75 } do
			local T = C2 * CFrame.new(1.35, dy, -s2.Z / 2)
			B:block(R, v(0.95, 0.95, 0.25), T * CFrame.new(0, 0, -0.08), SURR)
			B:block(R, v(0.55, 0.55, 0.25), T * CFrame.new(0, 0, -0.16) * ang(0, 0, 45), CONE_LT)
			B:block(R, v(0.22, 0.22, 0.2), T * CFrame.new(0, 0, -0.3), N_YELLOW, { mat = "Neon", name = "Tweeter" .. k })
		end

		------------------------------------------------------------ boombox
		local s3 = v(5.0, 2.3, 1.8)
		local C3 = CFrame.new(-0.1, Y0 + s1.Y + s2.Y + s3.Y / 2, -0.1) * ang(0, -6, 0)
		B:block(R, s3, C3, CYAN)
		B:block(R, v(s3.X + 0.1, 0.35, s3.Z + 0.1), C3 * CFrame.new(0, -s3.Y / 2 + 0.17, 0), CYAN_DK)
		B:block(R, v(s3.X + 0.1, 0.3, s3.Z + 0.1), C3 * CFrame.new(0, s3.Y / 2 - 0.15, 0), CYAN_LT)
		for k, sx in { -1, 1 } do
			local F = C3 * CFrame.new(sx * 1.6, -0.05, -s3.Z / 2)
			speaker(F, 0.72, N_YELLOW, (k == 1) and "BoomL" or "BoomR")
		end
		-- centre display with tiny equalizer bars + buttons on top
		local FD = C3 * CFrame.new(0, 0.05, -s3.Z / 2)
		B:block(R, v(1.5, 1.3, 0.2), FD * CFrame.new(0, 0, -0.08), SURR)
		local eq = { 0.35, 0.75, 0.55, 0.9 }
		for i, h in eq do
			B:block(R, v(0.22, h, 0.1), FD * CFrame.new(-0.51 + (i - 1) * 0.34, -0.5 + h / 2, -0.22), (i % 2 == 0) and N_PINK or N_CYAN, { mat = "Neon", name = "Eq" .. i })
		end
		for i = 0, 3 do
			B:block(R, v(0.4, 0.2, 0.4), C3 * CFrame.new(-0.9 + i * 0.6, s3.Y / 2 + 0.05, -0.3), (i % 2 == 0) and PINK or GOLD)
		end
		-- gold carry handle
		local HT = s3.Y / 2 + 1.0
		for _, sx in { -1, 1 } do
			B:block(R, v(0.4, 1.0, 0.4), C3 * CFrame.new(sx * 1.9, s3.Y / 2 + 0.5, 0.2), GOLD_DK)
		end
		local handle = B:block(R, v(4.2, 0.4, 0.45), C3 * CFrame.new(0, HT, 0.2), GOLD)
		B:block(R, v(2.0, 0.45, 0.55), C3 * CFrame.new(0, HT, 0.2), GOLD_LT)
		-- little antenna with a pink tip
		B:bar(R, (C3 * CFrame.new(2.2, s3.Y / 2, 0.5)).Position, (C3 * CFrame.new(2.9, s3.Y / 2 + 2.0, 0.5)).Position, 0.2, 0.2, "#c9cfdb")
		local tip = B:gem(R, v(0.35, 0.35, 0.35), C3 * CFrame.new(2.93, s3.Y / 2 + 2.1, 0.5), N_PINK, { name = "AntennaTip" })

		------------------------------------------------------------ fx
		B:emitter(tip, "sparkle", { name = "PartySparkle", color = { "#ff86d4", "#72e6ff", "#fff36a" }, rate = 3, size = 0.35 })
		B:emitter(handle, "glow", { name = "BeatGlow", color = "#ff5cc8", rate = 1, size = 0.7 })
		B:light(handle, { color = "#ff7ad6", brightness = 0.8, range = 10, name = "PartyLight" })
	end,
}
