let s:config = g:ctrlspace#context#Configuration.Instance()
let g:ctrlspace#bookmarks#Bookmarks = []

function! ctrlspace#bookmarks#AddToBookmarks(directory, name)
  let directory   = ctrlspace#util#NormalizeDirectory(a:directory)
  let jumpCounter = 0

  for i in range(0, len(g:ctrlspace#bookmarks#Bookmarks) - 1)
    if g:ctrlspace#bookmarks#Bookmarks[i].Directory == directory
      let jumpCounter = g:ctrlspace#bookmarks#Bookmarks[i].JumpCounter
      call remove(g:ctrlspace#bookmarks#Bookmarks, i)
      break
    endif
  endfor

  let bookmark = { "Name": a:name, "Directory": directory, "JumpCounter": jumpCounter }

  call add(g:ctrlspace#bookmarks#Bookmarks, bookmark)

  let lines     = []
  let bmRoots   = {}
  let cacheFile = s:config.CacheDir . "/.cs_cache"

  if filereadable(cacheFile)
    for oldLine in readfile(cacheFile)
      if (oldLine !~# "CS_BOOKMARK: ") && (oldLine !~# "CS_PROJECT_ROOT: ")
        call add(lines, oldLine)
      endif
    endfor
  endif

  for bm in g:ctrlspace#bookmarks#Bookmarks
    call add(lines, "CS_BOOKMARK: " . bm.Directory . g:ctrlspace#context#Separator . bm.Name)
    let bmRoots[bm.Directory] = 1
  endfor

  for root in keys(g:ctrlspace#roots#ProjectRoots)
    if !exists("bmRoots[root]")
      call add(lines, "CS_PROJECT_ROOT: " . root)
    endif
  endfor

  call writefile(lines, cacheFile)

  let g:ctrlspace#roots#ProjectRoots[bookmark.Directory] = 1

  return bookmark
endfunction

function! ctrlspace#bookmarks#FindActiveBookmark()
  let projectRoot = ctrlspace#util#NormalizeDirectory(empty(g:ctrlspace#roots#ProjectRoot) ? fnamemodify(".", ":p:h") : g:ctrlspace#roots#ProjectRoot)

  for bookmark in g:ctrlspace#bookmarks#Bookmarks
    if ctrlspace#util#NormalizeDirectory(bookmark.Directory) == projectRoot
      let bookmark.JumpCounter = ctrlspace#jumps#IncrementJumpCounter()
      return bookmark
    endif
  endfor

  return {}
endfunction