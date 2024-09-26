<div align="center">

# jq.nvim

[![Lua](https://img.shields.io/badge/Lua-blue.svg?style=for-the-badge&logo=lua)](http://www.lua.org)
[![Neovim](https://img.shields.io/badge/Neovim%200.10+-green.svg?style=for-the-badge&logo=neovim)](https://neovim.io)

</div>

# Why? 

If you're anything like me, you spend more time than you wish you did filtering API results with JQ  
This normally requires a workflow something like `send nvim to background -> make request -> pipe into JQ`  
The context switch generally kills some of my momentum, and I somehow seem to always forget to run `fg` instead of spinning up a new nvim process  

And frankly, I wanted to start to figure out how to write Neovim plugins

# What?

jq.nvim is a dead-simple wrapper around jq. Paste JSON into the json-in buffer, and write a jq filter in the jq-input buffer.

## What's next?
- Support jq command-line arguments
- generalize functionality to allow for jq alternatives (i.e. yq)

