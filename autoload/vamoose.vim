" vamoose.vim
" Author: Ted Tibbetts <intuited à j'y aimé à y elle point com>
" License: Licensed under the same terms as Vim itself.
" Vim Access to Macros in OpenOffice Session Environments
" This plugin exists for the purpose of
" making editing OOBasic macros ever so slightly less painful.

" Translate URLs between Dictionaries and Strings
funct! vamoose#parse_url(url)
  " vamoose URLs, used as buffer names,
  " have the form "vamoose://host:port//document//library.module"
  " wherein the "host:port//" is optional.
  " If either host or port is given, the delimiting colon must be included.
  " If a dictionary is passed, that dictionary is returned directly.
  if type(a:url) == type({})
    return a:url
  endif

  let components = {}
  let parts = split(a:url, '//')
  if parts[0] !=# 'vamoose:'
    throw "vamoose: tried to parse non-vamoose URL ".a:url
  endif
  if len(parts) < 3
    throw "vamoose: invalid URL '".a:url."': not enough parts."
  elseif len(parts) == 3
    let [components.document, libmod] = parts[1:2]
  elseif len(parts) == 4
    let [hostport, components.document, libmod] = parts[1:3]
    let [host, port] = split(hostport, ':')
    for [k, v] in [['host', host], ['port', port]]
      if strlen(v)
        components[k] = p
      endif
    endfor
  else
    throw "vamoose: invalid URL '".a:url."': too many parts."
  endif
  let [components.library, components.module] = split(libmod, '\.')

  return components
endfunct

funct! vamoose#make_url(components)
  let components = extend(copy(a:components), {'host': '', 'port': ''}, 'keep')
  let libmod = join('.', [components.library, components.module])
  if strlen(components.host) || strlen(components.port)
    let hostport = join(':', [components.host, components.port])
    let url = scheme . '://' . hostport . '//' . components.document . '//' . libmod
  else
    let url = scheme . '://' . components.document . '//' . libmod
  endif
endfunct

" vamoose#global_url([new_url[, keep]])
" The default url, used to override missing url components.
" This is mostly useful for setting the host and port.
" If `new_url` is given, it is applied to the existing url.
" `keep` is passed as the third parameter to |extend()|,
" unless `keep` is 'replace'.
" In that case, the entire global URL is replaced with `url`.
funct! vamoose#global_url(...)
  if a:0
    if a:0 > 1 && a:2 ==# 'replace'
      let s:url = a:1
    else
      call extend(s:url, a:1, a:0 > 1 ? a:2 : 'keep')
    endif
  endif

  if !exists('s:url')
    let s:url = {}
  endif

  return s:url
endfunct
    
" vamoose#buffer_url([buffer])
" vamoose URL components, based on the buffer name of `buffer`.
" `buffer` defaults to '%'.
funct! vamoose#buffer_url(...)
  let buffer = a:0 ? a:1 : bufnr('%')
  return vamoose#parse_url(bufname(buffer))
endfunct

" vamoose#pull([url[, override]])
" Return the contents of the module for the current buffer
" as a List of Strings.
" Arguments:
"   url: Can be given as a URL string or a dictionary of components.
"        If not given, the current buffer's URL is used.
"   override: Unless given as a truthy value, missing elements in `url`
"             are filled in with components from the buffer URL.
funct! vamoose#pull(...)
  let url = a:0 ? vamoose#parse_url(a:1) : {}

  if a:0 <= 1 || !a:2
    let url = extend(copy(url), vamoose#buffer_url(), 'keep')
  endif
  call extend(url, vamoose#global_url(), 'keep')

  let exchange_kwargs = filter(copy(url), 'index(["host", "port"], v:key) >= 0')
  let pull_args = [url.document, url.library, url.module]

  python vim.current.buffer[:] = map(str, oomax.Exchange(**vim.eval('exchange_kwargs')).pull(*vim.eval('pull_args')))
  set ft=basic
endfunct

""--  " vamoose#set(url, [combine])
""--  " Sets the current buffer's URL to `url`.
""--  " If `combine` is nonzero,
""--  " existing components in the current buffer URL are retained.
""--  funct! vamoose#set(url, ...)
""--    let url = vamoose#parse_url(a:url)
""--    if a:0 && a:1
""--      call extend(url, vamoose#buffer_url(), 'keep')
""--    endif
""--    let 



""~~  funct! Test(p1, ...)
""~~    echo 'p1: '.a:p1
""~~    echo '...: '.string(a:000)
""~~    if a:0 && a:1
""~~      echo 'a:0 && a:1'
""~~    else
""~~      if a:0
""~~        echo 'a:0'
""~~        if a:0 && !a:1
""~~          echo 'a:0 && !a:1'
""~~        endif
""~~      else
""~~        echo '!a:0'
""~~      endif
""~~    endif
""~~  endfunct

python <<EOF
# TODO: make sure that `oomax` is available and of an appopriate version.
#       The script should launch an ``easy_install`` of it.
import vim
import oomax
EOF
