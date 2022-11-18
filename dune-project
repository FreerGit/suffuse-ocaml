(lang dune 3.5)

(name suffuse)

(generate_opam_files true)

(source
 (github username/reponame))

(authors "Author Name")

(maintainers "Maintainer Name")

(license LICENSE)

(documentation https://url/to/documentation)

(package
 (name suffuse)
 (synopsis "A short synopsis")
 (description "A longer description")
 (depends 
  ocaml
  dune
  async 
  cohttp_async_websocket 
  core 
  core_bench 
  cmdliner 
  ppx_deriving 
  ppx_jane 
  ppx_string 
  ppx_expect 
  ppx_bench 
  ppx_yojson_conv
  )
 (tags
  (topics "to describe" your project)))

; See the complete stanza docs at https://dune.readthedocs.io/en/stable/dune-files.html#dune-project
