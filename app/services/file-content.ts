export type R3Operation = 'READ'|'EXTRACT'|'TRANSFORM';
export async function processFileContent(input:{operation:R3Operation;artifact:{uri?:string;name?:string;mimeType:string;base64:string}}){
  if(!input.artifact.base64) throw new Error('R3_REQUIRES_ARTIFACT');
  const invocation={user_message:'R3_FILE_CONTENT',r3_operation:input.operation,attachments:[input.artifact],stream:false};
  // R3 is executed by the existing SH Runtime; client code does not gain file authority.
  return invocation;
}
