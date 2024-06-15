local ls = require 'luasnip'
local s = ls.snippet
local i = ls.insert_node
local d = ls.dynamic_node
local sn = ls.snippet_node
local fmta = require('luasnip.extras.fmt').fmta

ls.cleanup() -- for testing

ls.add_snippets('javascript', {
  s(
    { trig = '$ctrl', name = 'angularjs controller' },
    fmta(
      [[
    angular.module('kkrm').controller('<name>', function($scope<args>){
      <body>
    });
    ]],
      {
        name = d(1, function()
          local fname = vim.fs.basename(vim.api.nvim_buf_get_name(0))
          local splitted = vim.split(fname, '.', { plain = true })
          return sn(nil, {
            i(1, splitted[1]),
          })
        end),
        args = i(2),
        body = i(0),
      }
    )
  ),
  s(
    { trig = '$ctrl2', name = 'separate ctrl' },
    fmta(
      [[
    angular.module('kkrm').controller('<name>', <name>);
    /**
     * @typedef Scope
     * @prop {any} someProp описание
     */

    /**
     * @param {Scope} $scope
     */
    function <name>($scope<args>) {
      <body>
    };
    ]],
      {
        name = d(1, function()
          local fname = vim.fs.basename(vim.api.nvim_buf_get_name(0))
          local splitted = vim.split(fname, '.', { plain = true })
          return sn(nil, {
            i(1, splitted[1]),
          })
        end),
        args = i(2),
        body = i(0),
      },
      { repeat_duplicates = true }
    )
  ),
  s(
    { trig = '$service', name = 'separate sevice' },
    fmta(
      [[
    angular.module('kkrm').service('<name>', <name>);
    /**
     * @param {ReturnType<<restModelServ>>} restModelServ
     * @param {angular.IHttpService} $http
     */
    function <name>(restModelServ, $http<args>) {
      var self = {
        <body>
      };

      return self;
    };
    ]],
      {
        name = d(1, function()
          local fname = vim.fs.basename(vim.api.nvim_buf_get_name(0))
          local splitted = vim.split(fname, '.', { plain = true })
          return sn(nil, {
            i(1, splitted[1]),
          })
        end),
        args = i(2),
        body = i(0),
      },
      { repeat_duplicates = true }
    )
  ),
  s(
    { trig = 'sfn', name = 'scope function' },
    fmta(
      [[
    $scope.<name> = function <name>(<args>) {
      <body>
    };
    ]],
      { name = i(1, 'name'), args = i(2), body = i(0) },
      { repeat_duplicates = true }
    )
  ),
  s(
    { trig = 'svar', name = 'scope variable' },
    fmta('$scope.<name> = <val>;', { name = i(1, 'name'), val = i(2, 'val') })
  ),
})

ls.add_snippets('python', {
  s(
    { trig = '#t', name = 'type comment' },
    fmta('# type: (<args>) ->> <ret>', { args = i(1, ''), ret = i(2, 'None') })
  ),
})
