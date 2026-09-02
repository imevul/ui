local args = { ... }
local version = args[1] or 'master'

local installDir = ''
local repoOwner = 'imevul'
local repoName = 'ui'


---@class Installer
local Installer = {}

local function ensureDir(path)
	local dir = fs.getDir(path)
	if dir ~= '' and not fs.exists(dir) then
		ensureDir(dir)
		fs.makeDir(dir)
	end
end

local function matchesFilter(path, filters)
	if type(filters) ~= 'table' then
		return true
	end
	for _, prefix in ipairs(filters) do
		if path == prefix or path:sub(1, #prefix + 1) == prefix .. '/' then
			return true
		end
	end
	return false
end

---Download a single file to a target folder
---@param url string URL of item to download
---@param target string Target path
function Installer:downloadItem(url, target)
	local request = http.get(url)
	if request == nil then
		error(('Failed to download %s to %s'):format(url, target))
	end

	ensureDir(target)
	local file = fs.open(target, 'w')
	file.write(request.readAll())
	file.close()
	request.close()
end

---List blobs under filters and download raw file contents
---@param owner string Name of the repository owner
---@param repo string Name of the repository
---@param ref string sha hash, or name of branch or tag
---@param filters table List of path prefixes to download
function Installer:downloadGitHubRepo(owner, repo, ref, filters)
	local url = ('https://api.github.com/repos/%s/%s/git/trees/%s?recursive=1'):format(owner, repo, ref)
	local request = http.get(url, {
		Accept = 'application/vnd.github.v3+json'
	})
	if request == nil then
		error(('Could not reach GitHub API for %s/%s (%s). Either the version does not exist, or the API limit has been reached'):format(owner, repo, ref))
	end

	local body = request.readAll()
	request.close()
	local response = textutils.unserializeJSON(body)
	if not response or not response.tree then
		error(('Invalid GitHub tree response for %s/%s (%s)'):format(owner, repo, ref))
	end
	if response.truncated then
		error(('GitHub tree for %s/%s (%s) was truncated'):format(owner, repo, ref))
	end

	for _, v in ipairs(response.tree) do
		if v.type == 'blob' and matchesFilter(v.path, filters) then
			local rawUrl = ('https://raw.githubusercontent.com/%s/%s/%s/%s'):format(owner, repo, ref, v.path)
			local target = installDir .. v.path
			print(('Downloading %s'):format(v.path))
			self:downloadItem(rawUrl, target)
		end
	end
end

---Installs the library to the default location
function Installer:install()
	print('Installing imevul/ui')
	print('Removing old files')
	fs.delete(installDir .. 'imevul/ui')

	print(('Downloading GitHub repo %s/%s (%s) to %s'):format(repoOwner, repoName, version, installDir))
	self:downloadGitHubRepo(repoOwner, repoName, version, { 'imevul' })
	print('Done')
end

---Uninstalls from the default location
function Installer:uninstall()
	print('Uninstalling imevul/ui')
	fs.delete(installDir .. 'imevul/ui')
	print('Done')
end


if version == 'remove' then
	Installer:uninstall()
else
	Installer:install()
end
