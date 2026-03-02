function _my_deploy_rm
    rm -rf node_modules/ && pnpm install && npm run deploy test5 (git branch --show-current)
end
