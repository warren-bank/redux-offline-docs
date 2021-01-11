const fs   = require('fs')
const path = require('path')

const root = (process.argv.length < 3)
  ? process.cwd()
  : path.resolve(process.cwd(), process.argv[2])

{
  const stats = fs.statSync(root, {throwIfNoEntry: false})

  if (!stats || !stats.isDirectory()) {
    console.log('Error: input directory path does not exist')
    process.exit(1)
  }
}

// https://pandoc.org/MANUAL.html#epub-metadata
// https://pandoc.org/MANUAL.html#extension-yaml_metadata_block

const filter_yaml_metadata_block = (page) => {
  let modified = false
  let index, meta, lines

  index = page.indexOf('---')
  if (index === 0) {
    index = page.indexOf('---', 3)
    if (index >= 0) {
      index += 3
      meta = page.substring(0, index)
      page = page.substring(index)

      lines = meta.split(/[\r\n]+/g)
      meta  = null

      lines = lines.map(function(line){
        let name, val
        index = line.indexOf(':')
        if (index === -1) return line
        index += 1
        name = line.substring(0, index)
        val  = line.substring(index)

        index = val.indexOf(':')
        if (index === -1) return line

        modified = true
        val  = val.replace(/[:]/g, ' -')
        line = name + val
        return line
      })

      page  = lines.join("\n") + page
      lines = null
    }
  }
  return {modified, page}
}

const process_markdown_file = (filepath) => {
  const {modified, page} = filter_yaml_metadata_block(
    fs.readFileSync(filepath, {encoding: "utf8"})
  )

  if (modified) {
    fs.writeFileSync(filepath, page, {encoding: "utf8"})
  }
}

const walk_file_tree = (dirpath) => {
  const entries = fs.readdirSync(dirpath, {encoding: "utf8", withFileTypes: true})

  entries.forEach(dirent => {
    if (dirent.isFile() && dirent.name.endsWith('.md')) {
      process_markdown_file(path.join(dirpath, dirent.name))
    }
    if (dirent.isDirectory() && !((dirent.name === '.') || (dirent.name === '..'))) {
      walk_file_tree(path.join(dirpath, dirent.name))
    }
  })
}

walk_file_tree(root)
