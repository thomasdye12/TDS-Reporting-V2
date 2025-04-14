<?php
class BrowserStream 
{

	/**
   * enable() enables writing streams of texts to the browser (handy for showing progress etc)
   * 
   * NOTE #1: make sure to flush after writing like so: 
   *          print("foo"); ob_flush(); flush();
   *
   * NOTE #2: disable apache gzip buffering in .htaccess like so: 
   *          RewriteRule ^(test\.php)$ $1 [NS,E=no-gzip:1,E=dont-vary:1]
   *
   * @access private
   * @return void
   */
  public static function enable(){
    @ini_set('zlib.output_compression', 'Off');
    @ini_set('output_buffering', 'Off');
    @ini_set('output_handler', '');
		if( function_exists('apache_setenv') ) // if this function is present, 
		@apache_setenv('no-gzip', 1);    // then the .htaccess line can be omitted
    header('Content-Type: text/event-stream');
    header('Cache-Control: no-cache'); // recommended to prevent caching of event data.
  }				

	/**
	 * print
	 * 
	 * @param mixed $str 
	 * @static
	 * @access public
	 * @return void
	 */
	public static function put($str){
		print($str); @ob_flush(); @flush();
	}

}

BrowserStream::enable();
BrowserStream::put("loading");
for( $i = 0; $i < 5; $i++ ){
    BrowserStream::put("\nthis is a new line".$i);
    sleep(1);
}
