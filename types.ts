export type Category={id:string;name:string;slug:string;icon?:string;color?:string}
export type Location={division_id:string;district_id:string;upazila_id:string;area_id?:string}
export type Mistri={id:string;full_name:string;phone:string;whatsapp?:string;category?:Category;division?:string;district?:string;upazila?:string;area?:string;experience:number;description?:string;available:boolean;verified:boolean;rating:number;review_count:number;avatar_url?:string}
