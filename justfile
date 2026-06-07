root := justfile_directory()

test:
    @mkdir -p /tmp/muxi.nvim-test-runtime
    @chmod 700 /tmp/muxi.nvim-test-runtime
    @XDG_RUNTIME_DIR=/tmp/muxi.nvim-test-runtime NVIM_LOG_FILE=/tmp/muxi.nvim-test.log MUXI_TEST_REPO='{{ root }}' nvim --headless -u '{{ root }}/tests/minimal_init.lua' -i NONE -c "lua dofile('{{ root }}/tests/run.lua').run()" -c 'qa!'

fmt:
    stylua lua plugin tests

check: test
