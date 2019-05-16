component{

    function configure(){

        route( "/", "home.LaunchRequest" )
        
        route( "/:handler/:action" ).end();
    }

}