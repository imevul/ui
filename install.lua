local args = { ... }
local version = args[1] or '1.1.0'

local installDir = ''
local repoOwner = 'imevul'
local repoName = 'imevul-ui'


---@class Installer
local Installer = {}

---Download a single file to a target folder
---@param url string URL of item to download
---@param target string Target path
function Installer:downloadItem(url, target)
	local request = http.get(url)
	if request == nil then
		error(('Failed to download %s to %s'):format(url, target))
	end

	local file = fs.open(target, 'w')
	file.write(request.readAll())
	file.close()
	request.close()
end

---Recursively download items into their correct target path
---@param items table Table containing items to download
---@param path string Target path to download them to
function Installer:downloadItems(items, path)
	for _, v in ipairs(items) do
		if v.url == nil then
			self:downloadItems(v.items, path .. '/' .. v.path)
		else
			print(('Downloading %s to %s'):format(v.path, path))
			self:downloadItem(v.url, path .. '/' .. v.path)
		end
	end
end

---Fetches downloadable items from a GitHub repository and then downloads them
---@param owner string Name of the repository owner
---@param repo string Name of the repository
---@param sha string sha hash, or name of branch or tag
---@param filters table List of folders to download. All others will be skipped
function Installer:downloadGitHubRepo(owner, repo, sha, filters)
	local items = self:getGitHubTree(owner, repo, sha, filters)

	self:downloadItems(items, installDir)
end

---Recursively fetch a specific GitHub tree (files+folders)
---@param owner string Name of the repository owner
---@param repo string Name of the repository
---@param sha string sha hash, or name of branch or tag
---@param filters table A list of folders to download. All others will be skipped
function Installer:getGitHubTree(owner, repo, sha, filters)
	local url = ('https://api.github.com/repos/%s/%s/git/trees/%s'):format(owner, repo, sha)
	local request = http.get(url, {
		Accept = 'application/vnd.github.v3+json'
	})
	if request == nil then
		error(('Could not reach GitHub API for %s/%s (%s). Either the version does not exist, or the API limit has been reached'):format(owner, repo, sha))
	end

	local response = textutils.unserializeJSON(request.readAll())

	local items = {}
	for _, v in ipairs(response.tree) do
		local found = true
		if type(filters) == 'table' then
			found = false
			for _, v2 in ipairs(filters) do
				if v2 == v.path then
					found = true
					break
				end
			end
		end

		if found then
			if v.type == 'tree' then
				local subTree = self:getGitHubTree(owner, repo, v.sha)
				table.insert(items, {
					path = v.path,
					url = nil,
					items = subTree
				})
			elseif v.type == 'blob' then
				table.insert(items, {
					path = v.path,
					url = v.url,
					items = {}
				})
			end
		end
	end

	return items
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
