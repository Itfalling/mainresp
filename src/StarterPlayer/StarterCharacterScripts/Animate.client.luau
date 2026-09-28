--[[
	SCRIPT NAME:  Animate
	SCRIPT TYPE:  LocalScript (character script)
	WHERE:        StarterPlayer/StarterCharacterScripts/Animate
	DEPENDENCIES: none

	Replaces Roblox's default R15 "Animate" script (a script in
	StarterCharacterScripts with this name takes its place). The game plays
	its OWN movement animations — idle, walk, run, jump, fall, landing
	squash, swim, climb, sit — for every character on every client in
	StarterPlayerScripts/Client/Controllers/AnimationController (see
	Client/Animation/Locomotion). Keeping this script empty stops the
	default animations from fighting ours.
]]

-- Stop anything the Animator may already be playing (e.g. from a respawn).
local character = script.Parent
local humanoid = character:WaitForChild("Humanoid", 10)
local animator = humanoid and humanoid:WaitForChild("Animator", 10)
if animator and animator:IsA("Animator") then
	for _, track in animator:GetPlayingAnimationTracks() do
		track:Stop(0)
	end
end
