function _my_deploy_rm
    rm -rf node_modules/ && pnpm install && npm run deploy $MY_DEPLOY_ENV (git branch --show-current)
end
