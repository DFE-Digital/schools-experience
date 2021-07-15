
|Vulnerability ID      |     Package              |     Severity   |     Fix      | Type |      Comment| 
|----------------------|--------------------------|----------------|--------------|------|------|
|CVE-2008-4318         |     observer-0.1.0       |     High       |     None     |  gem |  gem list shows gem not to be used    | 
|CVE-2021-33587        |     css-what-3.4.2       |     High       |     None     |  npm    || 
|GHSA-8cr8-4vfw-mr7h   |     rexml-3.2.3.1        |     High       |     3.2.5    |  gem    | gem list rexml proves 3.2.5 is used version| 
|GHSA-fp4w-jxhp-m23p   |     bundler-2.1.4        |     High       |     2.2.10   |  gem    | Bundler List proves that bundler 2.2.23 is the only installed bundler in the path  | 
|GHSA-ww39-953v-wcq6   |     glob-parent-3.1.0    |     High       |     5.1.2    |  npm    || 
|CVE-2021-23382        |     postcss-6.0.23       |     Medium     |     None     |  npm    || 
|CVE-2021-3541         |     libxml2-2.9.10       |     Medium     |     None     |  APKG   ||  
|GHSA-257v-vj4p-3w2h   |     color-string-0.3.0   |     Medium     |     1.5.5    |  npm    || 

## Checking Gems are used
Gems are checked by running the command inside the docker image, this will show if they are being used by the application.

docker run -it `image name` gem list `gem name`

## Checking NPM
NPM packages are a little more difficult to check as we are not presenting a docker endpoint which will show them. 