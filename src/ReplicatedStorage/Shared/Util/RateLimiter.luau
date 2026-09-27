--!strict
--[[
	SCRIPT NAME:  RateLimiter
	SCRIPT TYPE:  ModuleScript (shared utility)
	WHERE:        ReplicatedStorage/Shared/Util/RateLimiter
	DEPENDENCIES: none

	Token-bucket rate limiter. Each key (usually a Player) owns a bucket that
	refills at `rate` tokens per second up to `burst` tokens. Keys are held
	weakly so Player objects are released automatically when they leave.
]]

export type RateLimiter = {
	Rate: number,
	Burst: number,
	Check: (self: RateLimiter, key: any, cost: number?) -> boolean,
	Reset: (self: RateLimiter, key: any) -> (),
}

type Bucket = { Tokens: number, Last: number }

local RateLimiter = {}
RateLimiter.__index = RateLimiter

function RateLimiter.new(rate: number, burst: number): RateLimiter
	assert(rate > 0 and burst > 0, "RateLimiter needs positive rate and burst")
	local self = setmetatable({
		Rate = rate,
		Burst = burst,
		_buckets = setmetatable({} :: { [any]: Bucket }, { __mode = "k" }),
	}, RateLimiter)
	return (self :: any) :: RateLimiter
end

function RateLimiter.Check(self: any, key: any, cost: number?): boolean
	local price = cost or 1
	local now = os.clock()
	local bucket: Bucket? = self._buckets[key]
	if not bucket then
		bucket = { Tokens = self.Burst, Last = now }
		self._buckets[key] = bucket
	end
	assert(bucket)
	bucket.Tokens = math.min(self.Burst, bucket.Tokens + (now - bucket.Last) * self.Rate)
	bucket.Last = now
	if bucket.Tokens >= price then
		bucket.Tokens -= price
		return true
	end
	return false
end

function RateLimiter.Reset(self: any, key: any)
	self._buckets[key] = nil
end

return RateLimiter
